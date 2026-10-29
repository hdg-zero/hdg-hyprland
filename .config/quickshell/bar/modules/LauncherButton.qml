import QtQuick
import Quickshell
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../../launcher"

BarPillButton {
    id: root
    description: "Lanceur"

    icon: "󰣇"
    iconColor: BarStyle.accentText
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    
    onClicked: {
        LauncherService.toggle();
    }
}
