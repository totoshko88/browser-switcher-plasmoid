// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Main QML

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5S
import org.kde.notification as Notification

PlasmoidItem {
    id: root

    // Properties
    property var browsers: []
    property string currentBrowserId: ""
    property string currentBrowserIcon: "web-browser"
    property bool isLoading: true
    property bool isSwitching: false
    property string errorMessage: ""
    property string pendingBrowserId: ""
    property string lastSelectedBrowserId: ""
    property bool xdgSettingsAvailable: true

    // Browser detection state
    property var pendingDesktopFiles: []
    property var parsedBrowsers: []
    property var seenExecs: ({})

    // Command callbacks for the executable DataSource
    property var commandCallbacks: ({})

    // Cache key for localStorage
    readonly property string cacheKey: "browserSwitcher_browserCache"

    // Configuration bindings
    readonly property int refreshIntervalMs: Plasmoid.configuration.refreshInterval * 60000
    readonly property bool showBrowserType: Plasmoid.configuration.showBrowserType
    readonly property bool autoClosePopup: Plasmoid.configuration.autoClosePopup

    // Compact representation (icon in panel/tray)
    compactRepresentation: CompactRepresentation {
        currentIcon: root.currentBrowserIcon
        onActivated: root.expanded = !root.expanded
    }

    // Full representation (popup menu)
    fullRepresentation: FullRepresentation {
        browsers: root.browsers
        currentBrowserId: root.currentBrowserId
        lastSelectedBrowserId: root.lastSelectedBrowserId
        isLoading: root.isLoading
        isSwitching: root.isSwitching
        errorMessage: root.errorMessage
        showBrowserType: root.showBrowserType
        onBrowserSelected: (browserId) => root.setDefaultBrowser(browserId)
        onRefreshRequested: root.refresh()
        onConfigureRequested: root.openSystemSettings()
        onLaunchRequested: root.launchCurrentBrowser()
    }

    // Prefer compact representation in panel
    preferredRepresentation: compactRepresentation

    // Switch dimensions for popup
    switchWidth: Kirigami.Units.gridUnit * 15
    switchHeight: Kirigami.Units.gridUnit * 10

    // Tooltip
    toolTipMainText: i18n("Browser Switcher")
    toolTipSubText: {
        if (isLoading) return i18n("Loading...")
        const browser = browsers.find(b => b.id === currentBrowserId)
        return browser ? i18n("Current: %1", browser.name) : i18n("No default browser set")
    }

    // Icon for panel
    Plasmoid.icon: currentBrowserIcon

    // Context menu actions
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Configure Default Applications...")
            icon.name: "configure"
            onTriggered: root.openSystemSettings()
        },
        PlasmaCore.Action {
            text: i18n("Refresh")
            icon.name: "view-refresh"
            enabled: !root.isLoading && !root.isSwitching
            onTriggered: root.refresh()
        },
        PlasmaCore.Action {
            text: i18n("Launch Browser")
            icon.name: root.currentBrowserIcon
            enabled: root.currentBrowserId.length > 0
            onTriggered: root.launchCurrentBrowser()
        }
    ]

    // Command execution timeout
    Timer {
        id: commandTimeout
        interval: 10000
        onTriggered: {
            isLoading = false
            isSwitching = false
            errorMessage = i18n("Operation timed out. Please try again.")
            console.warn("Browser Switcher: Command execution timed out")
        }
    }

    // Timer to close popup after successful switch
    Timer {
        id: closeTimer
        interval: 600
        onTriggered: {
            if (root.autoClosePopup) {
                root.expanded = false
            }
            lastSelectedBrowserId = ""
        }
    }

    // Timer for periodic refresh (monitors external changes)
    Timer {
        id: refreshTimer
        interval: root.refreshIntervalMs
        repeat: true
        running: true
        onTriggered: {
            if (!isLoading && !isSwitching) {
                silentRefreshDefault()
            }
        }
    }

    // Clear last selected indicator after delay
    Timer {
        id: clearSelectionTimer
        interval: 2000
        onTriggered: lastSelectedBrowserId = ""
    }

    // Retry timer for transient failures
    Timer {
        id: retryTimer
        interval: 500
        property string browserId: ""
        property int retryCount: 0
        onTriggered: {
            if (browserId && retryCount < 3) {
                setDefaultBrowserInternal(browserId, retryCount)
            }
        }
    }

    // Reusable DataSource for command execution (avoids memory leaks from Qt.createQmlObject)
    P5S.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]?.trim() ?? ""
            var exitCode = data["exit code"] ?? -1
            disconnectSource(sourceName)

            if (root.commandCallbacks[sourceName]) {
                root.commandCallbacks[sourceName](stdout, exitCode)
                delete root.commandCallbacks[sourceName]
            }
        }
    }

    // Notification component for user feedback
    Notification.Notification {
        id: notification
        componentName: "plasma_workspace"
        eventId: "notification"
        title: i18n("Browser Switcher")
    }

    Component.onCompleted: {
        loadCachedBrowsers()
        checkXdgSettings()
    }

    // Show notification to user
    function showNotification(message, isError) {
        notification.text = message
        notification.iconName = isError ? "dialog-error" : "dialog-information"
        notification.sendEvent()
    }

    // Check if xdg-settings is available
    function checkXdgSettings() {
        runCommand("which xdg-settings", (stdout, exitCode) => {
            if (exitCode !== 0 || !stdout) {
                xdgSettingsAvailable = false
                errorMessage = i18n("xdg-settings not found. Please install xdg-utils package.")
                isLoading = false
                console.error("Browser Switcher: xdg-settings not available")
            } else {
                xdgSettingsAvailable = true
                refresh()
            }
        })
    }

    // Load cached browsers for faster startup
    function loadCachedBrowsers() {
        try {
            var cached = Plasmoid.configuration.browserCache
            if (cached && cached.length > 0) {
                var data = JSON.parse(cached)
                if (data.browsers && Array.isArray(data.browsers)) {
                    browsers = data.browsers
                    console.log("Browser Switcher: Loaded", browsers.length, "browsers from cache")
                }
            }
        } catch (e) {
            console.log("Browser Switcher: No valid cache found")
        }
    }

    // Launch the current default browser
    function launchCurrentBrowser() {
        if (!currentBrowserId) {
            showNotification(i18n("No default browser set"), true)
            return
        }

        runCommand("xdg-open https://", (stdout, exitCode) => {
            if (exitCode !== 0) {
                showNotification(i18n("Failed to launch browser. Please check your default browser settings."), true)
                console.error("Browser Switcher: Failed to launch browser, exit code:", exitCode)
            }
        })
    }

    // Save browsers to cache
    function saveBrowserCache() {
        try {
            var data = JSON.stringify({ browsers: browsers, timestamp: Date.now() })
            Plasmoid.configuration.browserCache = data
        } catch (e) {
            console.warn("Browser Switcher: Failed to save cache:", e)
        }
    }

    // Refresh browser list and current default
    function refresh() {
        if (!xdgSettingsAvailable) {
            checkXdgSettings()
            return
        }
        isLoading = true
        errorMessage = ""
        parsedBrowsers = []
        pendingDesktopFiles = []
        seenExecs = {}
        commandTimeout.restart()
        detectBrowsers()
    }

    // Silent refresh - only check current default without full rescan
    function silentRefreshDefault() {
        runCommand("xdg-settings get default-web-browser", (stdout, exitCode) => {
            if (exitCode === 0 && stdout && stdout.length > 0) {
                var newBrowserId = stdout.trim()
                if (currentBrowserId !== newBrowserId) {
                    currentBrowserId = newBrowserId
                    updateIcon()
                    var browser = browsers.find(b => b.id === newBrowserId)
                    var browserName = browser?.name ?? newBrowserId
                    showNotification(i18n("Default browser changed externally to %1", browserName), false)
                    console.log("Browser Switcher: External change detected, new default:", newBrowserId)
                }
            }
        })
    }

    // Open system default applications settings
    function openSystemSettings() {
        runCommand("kcmshell6 kcm_componentchooser 2>/dev/null || kcmshell5 componentchooser 2>/dev/null || systemsettings kcm_componentchooser", (stdout, exitCode) => {
            // Fire and forget - settings window opens independently
        })
    }

    // Generic command runner using the declared DataSource
    function runCommand(command, callback) {
        if (callback) {
            commandCallbacks[command] = callback
        }
        executable.connectSource(command)
    }

    // Escape shell argument to prevent injection
    function escapeShellArg(arg) {
        if (!arg) return "''"
        return "'" + String(arg).replace(/'/g, "'\\''") + "'"
    }

    // Detect browser type from path
    function detectBrowserType(filePath) {
        if (filePath.includes("/flatpak/")) return "Flatpak"
        if (filePath.includes("/snapd/")) return "Snap"
        return ""
    }

    // Detect installed browsers by finding .desktop files with WebBrowser category
    function detectBrowsers() {
        var searchPaths = [
            "/usr/share/applications",
            "/usr/local/share/applications",
            "$HOME/.local/share/applications",
            "/var/lib/snapd/desktop/applications",
            "/var/lib/flatpak/exports/share/applications",
            "$HOME/.local/share/flatpak/exports/share/applications"
        ]

        var cmd = "find " + searchPaths.join(" ") + " -maxdepth 1 -name '*.desktop' -type f 2>/dev/null | " +
                  "xargs grep -l 'WebBrowser' 2>/dev/null || echo ''"

        runCommand(cmd, (stdout, exitCode) => {
            handleBrowserDetection(stdout)
        })
    }

    // Handle browser detection results
    function handleBrowserDetection(stdout) {
        if (!stdout || stdout.length === 0) {
            console.warn("Browser Switcher: No browsers found in standard locations")
            finishBrowserDetection()
            return
        }

        var files = stdout.split('\n').filter(f => f && f.length > 0)

        if (files.length === 0) {
            finishBrowserDetection()
            return
        }

        pendingDesktopFiles = files.slice()
        var remaining = files.length

        // Parse each desktop file
        for (var i = 0; i < files.length; i++) {
            ((filePath) => {
                var cmd = "cat " + escapeShellArg(filePath)
                runCommand(cmd, (content, exitCode) => {
                    if (exitCode === 0 && content) {
                        var fileName = filePath.split('/').pop()
                        var browserType = detectBrowserType(filePath)
                        var browser = parseDesktopFile(content, fileName, browserType)
                        if (browser && !seenExecs[browser.exec]) {
                            parsedBrowsers.push(browser)
                            seenExecs[browser.exec] = true
                        }
                    }

                    remaining--
                    if (remaining <= 0) {
                        finishBrowserDetection()
                    }
                })
            })(files[i])
        }
    }

    // Parse desktop file content
    function parseDesktopFile(content, fileName, browserType) {
        var lines = content.split('\n')
        var entry = {}
        var inDesktopEntry = false

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            if (line === '[Desktop Entry]') {
                inDesktopEntry = true
                continue
            }

            if (line.startsWith('[') && line !== '[Desktop Entry]') {
                inDesktopEntry = false
                continue
            }

            if (!inDesktopEntry) continue

            var eqIndex = line.indexOf('=')
            if (eqIndex === -1) continue

            var key = line.substring(0, eqIndex).trim()
            var value = line.substring(eqIndex + 1).trim()

            // Only get non-localized keys
            if (key.indexOf('[') === -1) {
                entry[key] = value
            }
        }

        // Check if this is a web browser
        if (!entry.Categories || entry.Categories.indexOf('WebBrowser') === -1) {
            return null
        }

        // Check if it's hidden or should not be displayed
        if (entry.NoDisplay === 'true' || entry.Hidden === 'true') {
            return null
        }

        return {
            id: fileName,
            name: entry.Name || fileName.replace('.desktop', ''),
            icon: entry.Icon || 'web-browser',
            exec: entry.Exec ? entry.Exec.split(' ')[0] : '',
            type: browserType
        }
    }

    // Finish browser detection and get current default
    function finishBrowserDetection() {
        commandTimeout.stop()

        // Sort browsers alphabetically
        parsedBrowsers.sort((a, b) => a.name.localeCompare(b.name))
        browsers = parsedBrowsers

        // Save to cache for faster startup next time
        if (browsers.length > 0) {
            saveBrowserCache()
        }

        // Now get current default browser
        getCurrentDefaultBrowser()
    }

    // Get current default browser
    function getCurrentDefaultBrowser() {
        commandTimeout.restart()
        runCommand("xdg-settings get default-web-browser", (stdout, exitCode) => {
            commandTimeout.stop()
            handleGetDefaultBrowser(stdout, exitCode)
        })
    }

    // Handle get default browser response
    function handleGetDefaultBrowser(browserId, exitCode) {
        if (exitCode === 0 && browserId && browserId.length > 0) {
            if (currentBrowserId !== browserId) {
                currentBrowserId = browserId
                console.log("Browser Switcher: Default browser is", currentBrowserId)
            }
        } else {
            currentBrowserId = ""
        }

        updateIcon()
        isLoading = false
    }

    // Update the panel icon based on current browser
    function updateIcon() {
        if (!currentBrowserId) {
            currentBrowserIcon = "web-browser"
            return
        }

        var browser = browsers.find(b => b.id === currentBrowserId)
        currentBrowserIcon = browser?.icon ?? "web-browser"
    }

    // Verify browser desktop file exists before switching
    function verifyBrowserExists(browserId, callback) {
        var searchPaths = [
            "/usr/share/applications/" + browserId,
            "/usr/local/share/applications/" + browserId,
            "$HOME/.local/share/applications/" + browserId,
            "/var/lib/snapd/desktop/applications/" + browserId,
            "/var/lib/flatpak/exports/share/applications/" + browserId,
            "$HOME/.local/share/flatpak/exports/share/applications/" + browserId
        ]
        var cmd = "test -f " + searchPaths.map(p => escapeShellArg(p)).join(" -o -f ") + " && echo 'exists'"
        runCommand(cmd, (stdout, exitCode) => {
            callback(stdout.indexOf("exists") !== -1)
        })
    }

    // Set default browser (public API)
    function setDefaultBrowser(browserId) {
        if (isSwitching || isLoading) return
        setDefaultBrowserInternal(browserId, 0)
    }

    // Internal browser switching with retry support
    function setDefaultBrowserInternal(browserId, retryCount) {
        isSwitching = true
        errorMessage = ""
        pendingBrowserId = browserId
        lastSelectedBrowserId = browserId
        commandTimeout.restart()

        // Verify the browser still exists before attempting to switch
        verifyBrowserExists(browserId, (exists) => {
            if (!exists) {
                commandTimeout.stop()
                isSwitching = false
                errorMessage = i18n("Browser not found. It may have been uninstalled.")
                lastSelectedBrowserId = ""
                showNotification(errorMessage, true)
                // Refresh the list to remove stale entries
                refresh()
                return
            }

            runCommand("xdg-settings set default-web-browser " + escapeShellArg(browserId), (stdout, exitCode) => {
                commandTimeout.stop()

                if (exitCode !== 0 && retryCount < 2) {
                    console.log("Browser Switcher: Retry", retryCount + 1, "for", browserId)
                    retryTimer.browserId = browserId
                    retryTimer.retryCount = retryCount + 1
                    retryTimer.start()
                    return
                }

                handleSetDefaultBrowser(exitCode === 0)
            })
        })
    }

    // Handle set default browser response
    function handleSetDefaultBrowser(success) {
        isSwitching = false

        if (success && pendingBrowserId) {
            currentBrowserId = pendingBrowserId
            updateIcon()
            errorMessage = ""
            closeTimer.start()
            var browser = browsers.find(b => b.id === pendingBrowserId)
            console.log("Browser Switcher: Successfully set default browser to", pendingBrowserId)
        } else if (!success) {
            errorMessage = i18n("Failed to set default browser. Check permissions.")
            lastSelectedBrowserId = ""
            showNotification(errorMessage, true)
            console.error("Browser Switcher: Failed to set default browser to", pendingBrowserId)
        }

        pendingBrowserId = ""
    }
}
