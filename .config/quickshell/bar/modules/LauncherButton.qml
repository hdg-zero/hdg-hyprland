import QtQuick
import Quickshell.Hyprland
import "../../theme"
import "../../components"

PillButton {
    id: root

    icon: "󰣇"
    iconColor: Theme.accent
    customPaddingH: Theme.spacingMd
    customPaddingV: Theme.spacingSm
    
    onClicked: {
        Hyprland.dispatch("hl.dsp.exec_cmd('rofi -show drun')");
    }
}
