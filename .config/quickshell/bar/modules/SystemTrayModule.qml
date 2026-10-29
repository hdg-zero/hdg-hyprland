import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../popups"

// Zone de notification système regroupée sous un seul symbole : le survol (ou le clic)
// ouvre TrayPopup, qui liste les applis en arrière-plan avec leurs contrôles habituels.
BarPillButton {
    id: root

    function isNetworkItem(item) {
        if (!item) return false;
        var id = (item.id || "").toLowerCase();
        var title = (item.title || "").toLowerCase();
        return id.indexOf("nm-applet") !== -1 || id.indexOf("network") !== -1 || title.indexOf("network") !== -1 || title.indexOf("nm-applet") !== -1;
    }

    readonly property int itemCount: {
        var values = SystemTray.items ? SystemTray.items.values : [];
        var count = 0;
        for (var i = 0; i < values.length; i++) {
            if (values[i] && !isNetworkItem(values[i])) count++;
        }
        return count;
    }

    visible: itemCount > 0
    description: itemCount + " application(s) en arrière-plan"
    icon: "󰀻"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    // keepAlive : la popup est survolée souvent, on garde sa fenêtre après la première ouverture
    // au lieu de recréer surface Wayland + contexte GPU à chaque survol (audit §3).
    LazyPopup {
        id: trayLazy
        targetWindow: root.parentWindow
        anchor: root
        keepAlive: true
        popupComponent: Component {
            TrayPopup {
                parentWindow: root.parentWindow
                anchorItem: root
                isTrayItemVisible: function(item) { return item && !root.isNetworkItem(item); }
            }
        }
    }

    onClicked: trayLazy.toggle()
    onRightClicked: trayLazy.toggle()
}
