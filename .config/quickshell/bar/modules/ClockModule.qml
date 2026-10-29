import QtQuick
import Quickshell
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../popups"

BarPillButton {
    id: root
    description: "Calendrier · " + text

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
    iconColor: BarStyle.accentText
    text: Qt.formatDateTime(sysClock.date, "HH:mm")
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        clockLazy.toggle();
    }
}
