import QtQuick
import Quickshell
import "../../theme"
import "../../components"
import "../../launcher"

PillButton {
    id: root

    icon: "󰣇"
    iconColor: Theme.accent
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    
    onClicked: {
        LauncherService.toggle();
    }
}
