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
        Quickshell.execDetached(["rofi", "-show", "drun"]);
    }
}
