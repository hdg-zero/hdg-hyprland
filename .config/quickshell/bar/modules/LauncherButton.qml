import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../components"

PillButton {
    id: root

    icon: "󰣇"
    iconColor: Theme.accent
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    
    onClicked: {
        Quickshell.execDetached(["rofi", "-show", "drun"]);
    }
}
