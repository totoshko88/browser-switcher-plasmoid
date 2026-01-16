// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Compact Representation (Panel Icon)

import QtQuick
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

    property string currentIcon: "web-browser"

    signal activated()

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: i18n("Browser Switcher")
    Accessible.description: i18n("Click to switch default web browser")
    Accessible.onPressAction: compactRoot.activated()

    onClicked: compactRoot.activated()

    // Icon with proper transition handling
    Kirigami.Icon {
        id: browserIcon
        anchors.fill: parent
        source: currentIcon
        active: compactRoot.containsMouse

        // Track the pending icon during transition
        property string pendingSource: ""
        property bool isTransitioning: false

        // Smooth opacity behavior
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Handle icon changes with fade transition
    onCurrentIconChanged: {
        if (browserIcon.source === currentIcon) return

        if (!browserIcon.isTransitioning) {
            browserIcon.isTransitioning = true
            browserIcon.pendingSource = currentIcon
            browserIcon.opacity = 0.3
            iconTransitionTimer.start()
        } else {
            // Queue the new icon if already transitioning
            browserIcon.pendingSource = currentIcon
        }
    }

    Timer {
        id: iconTransitionTimer
        interval: Kirigami.Units.shortDuration
        onTriggered: {
            browserIcon.source = browserIcon.pendingSource
            browserIcon.opacity = 1.0
            browserIcon.isTransitioning = false

            // Check if another change was queued
            if (browserIcon.pendingSource !== compactRoot.currentIcon) {
                compactRoot.currentIconChanged()
            }
        }
    }
}
