import QtQuick
import Quickshell
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    ClockPopup {
        id: clockPopup
        parentWindow: root.parentWindow
        anchorItem: root
    }

    icon: "󰥔"
    iconColor: Theme.accent
    text: Qt.formatDateTime(sysClock.date, "HH:mm")
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        clockPopup.toggle();
    }
}
