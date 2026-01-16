// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Compact Representation (Panel Icon)

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

MouseArea {
    id: compactRoot

    property string currentIcon: "web-browser"

    signal activated()

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onClicked: compactRoot.activated()

    // Icon
    Kirigami.Icon {
        id: browserIcon
        anchors.fill: parent
        source: currentIcon
        active: compactRoot.containsMouse

        // Smooth icon transitions
        Behavior on source {
            SequentialAnimation {
                NumberAnimation {
                    target: browserIcon
                    property: "opacity"
                    to: 0.5
                    duration: 100
                }
                PropertyAction {
                    target: browserIcon
                    property: "source"
                }
                NumberAnimation {
                    target: browserIcon
                    property: "opacity"
                    to: 1.0
                    duration: 100
                }
            }
        }
    }
}
