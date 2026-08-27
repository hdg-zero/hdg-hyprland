import QtQuick
import Quickshell
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
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        pwrPopup.toggle();
    }

    onRightClicked: {
        Quickshell.execDetached(["wlogout", "--protocol", "layer-shell"]);
    }
}
