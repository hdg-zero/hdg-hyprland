import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property var toplevel: null
    property string appClass: ""
    property string iconSource: ""

    readonly property string winTitle: {
        if (!toplevel) return "";
        if (toplevel.title) return toplevel.title;
        if (toplevel.wayland && toplevel.wayland.title) return toplevel.wayland.title;
        if (toplevel.lastIpcObject && toplevel.lastIpcObject.title) return toplevel.lastIpcObject.title;
        return appClass || "Application";
    }

    readonly property string appName: {
        if (appClass) {
            var de = DesktopEntries.heuristicLookup(appClass);
            if (de && de.name) return de.name;
            return appClass.charAt(0).toUpperCase() + appClass.slice(1);
        }
        return "Application";
    }

    readonly property string workspaceName: {
        if (!toplevel) return "";
        if (toplevel.workspace && toplevel.workspace.name) return toplevel.workspace.name;
        if (toplevel.workspace && toplevel.workspace.id !== undefined) return "" + toplevel.workspace.id;
        if (toplevel.lastIpcObject && toplevel.lastIpcObject.workspace) {
            return "" + (toplevel.lastIpcObject.workspace.name || toplevel.lastIpcObject.workspace.id || "");
        }
        return "";
    }

    cardWidth: 280
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2
    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Theme.spacingSm
        RowLayout {
            Layout.fillWidth: true
            Image { id: appIcon; Layout.preferredWidth: 20; Layout.preferredHeight: 20; source: root.iconSource; asynchronous: true; sourceSize: Qt.size(20, 20); fillMode: Image.PreserveAspectFit; visible: status === Image.Ready }
            PopupGlyph { visible: !appIcon.visible; text: "󰣆" }
            PopupText { Layout.fillWidth: true; text: root.appName; font.pixelSize: 12; color: Theme.textSecondary }
            PopupText { visible: root.workspaceName !== ""; text: "WS " + root.workspaceName; font.pixelSize: 10; color: Theme.textSecondary }
        }
        PopupText { Layout.fillWidth: true; text: root.winTitle; wrapMode: Text.Wrap; maximumLineCount: 2 }
        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            PopupIconButton {
                glyph: "󰅖"
                description: "Fermer la fenêtre"
                enabled: root.toplevel !== null
                onClicked: {
                    if (!root.toplevel) return;
                    var addr = root.toplevel.address || "";
                    if (addr && addr.indexOf("0x") !== 0) addr = "0x" + addr;
                    if (root.toplevel.wayland && typeof root.toplevel.wayland.close === "function") root.toplevel.wayland.close();
                    else if (addr) Hyprland.dispatch("hl.dsp.window.close({ window = \"address:" + addr + "\" })");
                    root.close();
                }
            }
        }
    }
}
