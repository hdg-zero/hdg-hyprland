import QtQuick
import Quickshell
import "../../theme"
import ".."
import "../components"
import "../../caffeine"

BarPillButton {
    id: root

    property var parentWindow: null

    active: CaffeineService.active
    description: CaffeineService.active ? "Caféine activée" : "Caféine désactivée"
    icon: CaffeineService.active ? "󰅶" : "󰾪"
    iconColor: CaffeineService.active ? BarStyle.accentText : Theme.textDisabled
    text: CaffeineService.active ? "ON" : ""
    textColor: CaffeineService.active ? BarStyle.accentText : Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        CaffeineService.toggle();
    }

}
