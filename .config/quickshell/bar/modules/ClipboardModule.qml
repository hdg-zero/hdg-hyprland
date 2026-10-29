import QtQuick
import Quickshell
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../popups"

// Historique du presse-papiers (cliphist) : le clic ouvre ClipboardPopup.
// Pas d'ouverture au survol : la liste est relue à chaque ouverture.
BarPillButton {
    id: root

    property var parentWindow: null

    description: "Presse-papiers"
    icon: "󰅌"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    LazyPopup {
        id: clipboardLazy
        targetWindow: root.parentWindow
        anchor: root
        openOnHover: false
        popupComponent: Component {
            ClipboardPopup {
                parentWindow: root.parentWindow
                anchorItem: root
            }
        }
    }

    onClicked: clipboardLazy.toggle()
    onRightClicked: clipboardLazy.toggle()
}
