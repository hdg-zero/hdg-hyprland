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

    // Popup paresseuse : voir CpuModule pour le détail du mécanisme LazyPopup.
    LazyPopup {
        id: clockLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            ClockPopup {
                parentWindow: root.parentWindow
                anchorItem: root
            }
        }
    }

    icon: "󰥔"
    iconColor: Theme.accent
    text: Qt.formatDateTime(sysClock.date, "HH:mm")
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        clockLazy.toggle();
    }
}
