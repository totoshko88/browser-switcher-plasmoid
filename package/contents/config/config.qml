// SPDX-License-Identifier: GPL-3.0-or-later
// KDE Plasma Browser Switcher - Configuration

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configPage

    property alias cfg_refreshInterval: refreshIntervalSpinBox.value
    property alias cfg_showBrowserType: showBrowserTypeCheckBox.checked
    property alias cfg_autoClosePopup: autoClosePopupCheckBox.checked

    QQC2.SpinBox {
        id: refreshIntervalSpinBox
        Kirigami.FormData.label: i18n("Refresh interval (minutes):")
        from: 1
        to: 60
        value: 5
    }

    QQC2.CheckBox {
        id: showBrowserTypeCheckBox
        Kirigami.FormData.label: i18n("Show browser type:")
        text: i18n("Display Flatpak/Snap labels")
        checked: true
    }

    QQC2.CheckBox {
        id: autoClosePopupCheckBox
        Kirigami.FormData.label: i18n("Auto-close popup:")
        text: i18n("Close after switching browser")
        checked: true
    }
}
