import QtQuick
import Quickshell
import "../../theme"
import "../../components"
import "../../caffeine"
import "../popups"

PillButton {
    id: root

    property var parentWindow: null

    icon: CaffeineService.active ? "󰅶" : "󰾪"
    iconColor: CaffeineService.active ? Theme.accent : Theme.textDisabled
    text: CaffeineService.active ? "ON" : ""
    textColor: CaffeineService.active ? Theme.accent : Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    // Popup paresseuse au clic droit ou survol prolongé
    LazyPopup {
        id: caffeineLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            CaffeinePopup {
                parentWindow: root.parentWindow
                anchorItem: root
            }
        }
    }

    onClicked: {
        CaffeineService.toggle();
    }

    onRightClicked: {
        caffeineLazy.toggle();
    }
}
