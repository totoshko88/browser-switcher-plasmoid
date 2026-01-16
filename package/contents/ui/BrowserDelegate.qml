// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Browser List Item Delegate

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmaComponents.ItemDelegate {
    id: delegateRoot

    // Required properties for type safety (Plasma 6 best practice)
    required property int index
    required property var modelData

    property string browserId: modelData.id ?? ""
    property string browserName: modelData.name ?? ""
    property string browserIcon: modelData.icon ?? "web-browser"
    property string browserType: modelData.type ?? ""
    property bool isCurrentBrowser: false
    property bool isJustSelected: false
    property bool showType: true

    highlighted: isCurrentBrowser

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        // Browser icon
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: browserIcon
        }

        // Browser name and type
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: isCurrentBrowser ? i18n("%1 (current)", browserName) : browserName
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                visible: showType && browserType.length > 0
                text: browserType
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.7
                elide: Text.ElideRight
            }
        }

        // Success indicator for just-selected browser
        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            source: "emblem-ok-symbolic"
            visible: isJustSelected || isCurrentBrowser
            color: isJustSelected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor

            // Pulse animation for just-selected state
            SequentialAnimation on opacity {
                running: isJustSelected
                loops: 2
                NumberAnimation { to: 0.4; duration: 200 }
                NumberAnimation { to: 1.0; duration: 200 }
            }
        }
    }

    // Keyboard activation - emit clicked signal properly
    Keys.onReturnPressed: event => delegateRoot.clicked()
    Keys.onSpacePressed: event => delegateRoot.clicked()
}
