// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Full Representation (Popup Menu)

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: fullRoot

    property var browsers: []
    property string currentBrowserId: ""
    property bool isLoading: false

    signal browserSelected(string browserId)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 8
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.preferredHeight: Math.min(browserList.contentHeight + header.height + Kirigami.Units.smallSpacing * 2, Kirigami.Units.gridUnit * 20)

    header: PlasmaExtras.PlasmoidHeading {
        RowLayout {
            anchors.fill: parent
            
            PlasmaExtras.Heading {
                Layout.fillWidth: true
                level: 3
                text: i18n("Browser Switcher")
            }
            
            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                onClicked: root.refresh()
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

    // No browsers message
    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.largeSpacing * 2
        visible: !isLoading && browsers.length === 0
        iconName: "web-browser"
        text: i18n("No browsers found")
        explanation: i18n("Install a web browser to use this widget")
    }

    // Browser list
    ListView {
        id: browserList
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        visible: !isLoading && browsers.length > 0
        
        model: browsers
        spacing: Kirigami.Units.smallSpacing
        clip: true

        delegate: BrowserDelegate {
            width: browserList.width
            browserId: modelData.id
            browserName: modelData.name
            browserIcon: modelData.icon || "web-browser"
            isCurrentBrowser: modelData.id === currentBrowserId
            
            onClicked: fullRoot.browserSelected(browserId)
        }
    }
}
