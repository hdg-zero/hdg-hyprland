import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../../session"
import "../popups"

BarPillButton {
    id: root
    description: "Menu de session"

    // Popup paresseuse : voir CpuModule pour le détail du mécanisme LazyPopup.
    LazyPopup {
        id: pwrLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            PowerPopup {
                parentWindow: root.parentWindow
                anchorItem: root
            }
        }
    }

    icon: "⏻"
    iconColor: BarStyle.destructive
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        pwrLazy.toggle();
    }

    onRightClicked: {
        pwrLazy.toggle();
    }
}
