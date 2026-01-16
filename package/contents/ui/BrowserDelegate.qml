// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Browser List Item Delegate

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmaComponents.ItemDelegate {
    id: delegateRoot

    property string browserId: ""
    property string browserName: ""
    property string browserIcon: "web-browser"
    property bool isCurrentBrowser: false

    highlighted: isCurrentBrowser
    
    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        // Browser icon
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: browserIcon
        }

        // Browser name
        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: browserName
            elide: Text.ElideRight
        }

        // Checkmark for current browser
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            source: "checkmark"
            visible: isCurrentBrowser
            color: Kirigami.Theme.positiveTextColor
        }
    }

    // Hover effect
    background: Rectangle {
        color: {
            if (delegateRoot.pressed) {
                return Qt.rgba(Kirigami.Theme.highlightColor.r, 
                              Kirigami.Theme.highlightColor.g, 
                              Kirigami.Theme.highlightColor.b, 0.3)
            } else if (delegateRoot.hovered || delegateRoot.highlighted) {
                return Qt.rgba(Kirigami.Theme.highlightColor.r, 
                              Kirigami.Theme.highlightColor.g, 
                              Kirigami.Theme.highlightColor.b, 0.15)
            }
            return "transparent"
        }
        radius: Kirigami.Units.smallSpacing
        
        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }
    }
}
