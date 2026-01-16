// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Full Representation (Popup Menu)

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: fullRoot

    property var browsers: []
    property string currentBrowserId: ""
    property string lastSelectedBrowserId: ""
    property bool isLoading: false
    property bool isSwitching: false
    property string errorMessage: ""
    property bool showBrowserType: true

    signal browserSelected(string browserId)
    signal refreshRequested()
    signal configureRequested()
    signal launchRequested()

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 8
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Math.min(
        browserList.contentHeight + header.height + footer.height + Kirigami.Units.smallSpacing * 4,
        Kirigami.Units.gridUnit * 22
    )

    // Keyboard navigation
    Keys.onUpPressed: browserList.decrementCurrentIndex()
    Keys.onDownPressed: browserList.incrementCurrentIndex()
    Keys.onReturnPressed: {
        if (browserList.currentIndex >= 0 && browserList.currentIndex < browsers.length) {
            fullRoot.browserSelected(browsers[browserList.currentIndex].id)
        }
    }
    Keys.onEscapePressed: fullRoot.parent.expanded = false

    header: PlasmaExtras.PlasmoidHeading {
        id: header

        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaExtras.Heading {
                Layout.fillWidth: true
                level: 3
                text: i18n("Browser Switcher")
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                enabled: !isLoading && !isSwitching
                onClicked: fullRoot.refreshRequested()

                Accessible.name: i18n("Refresh")
                Accessible.description: i18n("Refresh browser list")

                PlasmaComponents.ToolTip {
                    text: i18n("Refresh browser list")
                }
            }
        }
    }

    // Loading indicator
    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        running: isLoading
        visible: isLoading
    }

    // Switching indicator overlay
    Item {
        anchors.fill: parent
        visible: isSwitching && !isLoading
        z: 10

        // Accessibility announcement for screen readers
        Accessible.role: Accessible.AlertMessage
        Accessible.name: i18n("Switching browser, please wait")

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            opacity: 0.7
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: isSwitching
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("Switching browser...")
            }
        }
    }

    // Success announcement for screen readers (invisible, only for accessibility)
    Item {
        id: successAnnouncement
        visible: false
        Accessible.role: Accessible.AlertMessage
        Accessible.name: ""

        function announce(browserName) {
            Accessible.name = i18n("Default browser changed to %1", browserName)
            visible = true
            announcementTimer.start()
        }

        Timer {
            id: announcementTimer
            interval: 3000
            onTriggered: {
                successAnnouncement.visible = false
                successAnnouncement.Accessible.name = ""
            }
        }
    }

    // Watch for successful browser switch to announce
    onLastSelectedBrowserIdChanged: {
        if (lastSelectedBrowserId && lastSelectedBrowserId === currentBrowserId) {
            var browser = browsers.find(b => b.id === currentBrowserId)
            if (browser) {
                successAnnouncement.announce(browser.name)
            }
        }
    }

    // Error message
    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.largeSpacing * 2
        visible: !isLoading && errorMessage.length > 0
        iconName: "dialog-error"
        text: i18n("Error")
        explanation: errorMessage

        helpfulAction: Kirigami.Action {
            text: i18n("Try Again")
            icon.name: "view-refresh"
            onTriggered: fullRoot.refreshRequested()
        }
    }

    // No browsers message
    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.largeSpacing * 2
        visible: !isLoading && browsers.length === 0 && errorMessage.length === 0
        iconName: "web-browser"
        text: i18n("No browsers found")
        explanation: i18n("Install a web browser to use this widget")
    }

    // Browser list
    ListView {
        id: browserList
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        visible: !isLoading && browsers.length > 0 && errorMessage.length === 0

        model: browsers
        spacing: Kirigami.Units.smallSpacing
        clip: true
        keyNavigationEnabled: true
        keyNavigationWraps: true
        highlightMoveDuration: Kirigami.Units.shortDuration
        currentIndex: -1

        // Accessibility
        Accessible.role: Accessible.List
        Accessible.name: i18n("Available browsers")

        // Focus management
        activeFocusOnTab: true
        onActiveFocusChanged: {
            if (activeFocus && currentIndex < 0 && count > 0) {
                currentIndex = 0
            }
        }

        delegate: BrowserDelegate {
            width: browserList.width
            isCurrentBrowser: modelData.id === currentBrowserId
            isJustSelected: modelData.id === lastSelectedBrowserId
            enabled: !isSwitching
            highlighted: ListView.isCurrentItem || isCurrentBrowser
            showType: showBrowserType

            onClicked: {
                browserList.currentIndex = index
                fullRoot.browserSelected(browserId)
            }

            Accessible.name: browserName
            Accessible.description: isCurrentBrowser
                ? i18n("%1, current default browser", browserName)
                : i18n("Set %1 as default browser", browserName)
        }

        // Highlight for keyboard navigation
        highlight: PlasmaExtras.Highlight {
            pressed: browserList.currentItem && browserList.currentItem.pressed
        }
    }

    footer: PlasmaExtras.PlasmoidHeading {
        id: footer
        position: PlasmaComponents.ToolBar.Footer
        visible: !isLoading && browsers.length > 0 && errorMessage.length === 0

        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.ToolButton {
                icon.name: "internet-web-browser"
                text: i18n("Launch")
                enabled: currentBrowserId.length > 0
                onClicked: fullRoot.launchRequested()

                Accessible.name: i18n("Launch current browser")
                Accessible.description: i18n("Open the current default web browser")

                PlasmaComponents.ToolTip {
                    text: i18n("Launch current browser")
                }
            }

            Item { Layout.fillWidth: true }

            PlasmaComponents.ToolButton {
                icon.name: "configure"
                text: i18n("Configure...")
                onClicked: fullRoot.configureRequested()

                Accessible.name: i18n("Configure Default Applications")
                Accessible.description: i18n("Open system settings to configure default applications")

                PlasmaComponents.ToolTip {
                    text: i18n("Configure Default Applications")
                }
            }
        }
    }
}
