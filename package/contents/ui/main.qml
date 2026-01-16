// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Main QML

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Properties
    property var browsers: []
    property string currentBrowserId: ""
    property string currentBrowserIcon: "web-browser"
    property bool isLoading: true

    // Compact representation (icon in panel/tray)
    compactRepresentation: CompactRepresentation {
        currentIcon: root.currentBrowserIcon
        onActivated: root.expanded = !root.expanded
    }

    // Full representation (popup menu)
    fullRepresentation: FullRepresentation {
        browsers: root.browsers
        currentBrowserId: root.currentBrowserId
        isLoading: root.isLoading
        onBrowserSelected: (browserId) => root.setDefaultBrowser(browserId)
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

    // DataSource for executing shell commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"] ? data["stdout"].trim() : ""
            var exitCode = data["exit code"]
            
            disconnectSource(sourceName)
            
            if (sourceName.indexOf("xdg-settings get") !== -1) {
                handleGetDefaultBrowser(stdout, exitCode)
            } else if (sourceName.indexOf("xdg-settings set") !== -1) {
                handleSetDefaultBrowser(exitCode === 0)
            } else if (sourceName.indexOf("grep") !== -1) {
                handleBrowserDetection(stdout)
            } else if (sourceName.indexOf("cat ") !== -1) {
                handleDesktopFileContent(sourceName, stdout)
            }
        }
    }

    // Pending desktop files to parse
    property var pendingDesktopFiles: []
    property var parsedBrowsers: []
    property var seenExecs: ({})

    Component.onCompleted: {
        refresh()
    }

    // Refresh browser list and current default
    function refresh() {
        isLoading = true
        browsers = []
        parsedBrowsers = []
        pendingDesktopFiles = []
        seenExecs = {}
        
        // First, detect browsers
        detectBrowsers()
    }

    // Detect installed browsers by finding .desktop files with WebBrowser category
    function detectBrowsers() {
        // Search in multiple directories including snap and flatpak
        var cmd = "grep -rl 'WebBrowser' " +
            "/usr/share/applications/ " +
            "/usr/local/share/applications/ " +
            "~/.local/share/applications/ " +
            "/var/lib/snapd/desktop/applications/ " +
            "/var/lib/flatpak/exports/share/applications/ " +
            "~/.local/share/flatpak/exports/share/applications/ " +
            "2>/dev/null | grep '\\.desktop$' || echo ''"
        executable.connectSource(cmd)
    }

    // Handle browser detection results
    function handleBrowserDetection(stdout) {
        if (!stdout || stdout.length === 0) {
            finishBrowserDetection()
            return
        }
        
        var files = stdout.split('\n').filter(function(f) { return f.length > 0 })
        
        if (files.length === 0) {
            finishBrowserDetection()
            return
        }
        
        pendingDesktopFiles = files.slice() // Copy array
        
        // Parse each desktop file
        for (var i = 0; i < files.length; i++) {
            var cmd = "cat '" + files[i] + "'"
            executable.connectSource(cmd)
        }
    }

    // Handle desktop file content
    function handleDesktopFileContent(sourceName, content) {
        // Extract filename from command
        var match = sourceName.match(/cat '([^']+)'/)
        if (!match) return
        
        var filePath = match[1]
        var fileName = filePath.split('/').pop()
        
        var browser = parseDesktopFile(content, fileName)
        if (browser && !seenExecs[browser.exec]) {
            parsedBrowsers.push(browser)
            seenExecs[browser.exec] = true
        }
        
        // Remove from pending
        var idx = pendingDesktopFiles.indexOf(filePath)
        if (idx !== -1) {
            pendingDesktopFiles.splice(idx, 1)
        }
        
        // Check if all files are processed
        if (pendingDesktopFiles.length === 0) {
            finishBrowserDetection()
        }
    }

    // Parse desktop file content
    function parseDesktopFile(content, fileName) {
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
            exec: entry.Exec ? entry.Exec.split(' ')[0] : ''
        }
    }

    // Finish browser detection and get current default
    function finishBrowserDetection() {
        // Sort browsers alphabetically
        parsedBrowsers.sort(function(a, b) { return a.name.localeCompare(b.name) })
        browsers = parsedBrowsers
        
        // Now get current default browser
        getCurrentDefaultBrowser()
    }

    // Get current default browser
    function getCurrentDefaultBrowser() {
        executable.connectSource("xdg-settings get default-web-browser")
    }

    // Handle get default browser response
    function handleGetDefaultBrowser(browserId, exitCode) {
        if (exitCode === 0 && browserId && browserId.length > 0) {
            if (currentBrowserId !== browserId) {
                currentBrowserId = browserId
                console.log("Browser Switcher: Default browser changed to", currentBrowserId)
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
        
        var browser = browsers.find(function(b) { return b.id === currentBrowserId })
        if (browser && browser.icon) {
            currentBrowserIcon = browser.icon
        } else {
            currentBrowserIcon = "web-browser"
        }
    }

    // Set default browser
    function setDefaultBrowser(browserId) {
        pendingBrowserId = browserId
        executable.connectSource("xdg-settings set default-web-browser " + browserId)
    }

    property string pendingBrowserId: ""

    // Handle set default browser response
    function handleSetDefaultBrowser(success) {
        if (success && pendingBrowserId) {
            currentBrowserId = pendingBrowserId
            updateIcon()
            root.expanded = false
        }
        pendingBrowserId = ""
    }

    // Timer for periodic refresh (monitors external changes)
    Timer {
        id: refreshTimer
        interval: 60000 // Check every 60 seconds
        repeat: true
        running: true
        
        onTriggered: {
            if (!isLoading) {
                // Only check current default, don't rescan all browsers
                executable.connectSource("xdg-settings get default-web-browser")
            }
        }
    }
}
