import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../../session"
import "../popups"

PillButton {
    id: root

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
    iconColor: Theme.destructive
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        pwrLazy.toggle();
    }

    onRightClicked: {
        SessionService.toggleSession();
    }
}
