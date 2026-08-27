import QtQuick
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    PowerPopup {
        id: pwrPopup
        parentWindow: root.parentWindow
        anchorItem: root
    }

    icon: "⏻"
    iconColor: Theme.destructive
    customPaddingH: Theme.spacingMd
    customPaddingV: Theme.spacingSm

    onClicked: {
        pwrPopup.toggle();
    }

    onRightClicked: {
        Hyprland.dispatch("hl.dsp.exec_cmd('wlogout --protocol layer-shell')");
    }
}
