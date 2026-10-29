import QtQuick
import Quickshell.Hyprland
import "../../theme"
import ".."

Item {
    id: root
    property real maximumWidth: 350
    readonly property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    visible: windowTitle.length > 0 && maximumWidth > 0
    implicitWidth: Math.max(0, Math.min(titleText.implicitWidth, maximumWidth))
    implicitHeight: 18
    Accessible.name: windowTitle
    Text {
        id: titleText
        anchors.fill: parent
        text: root.windowTitle
        textFormat: Text.PlainText
        font.family: BarStyle.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.textSecondary
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
}
