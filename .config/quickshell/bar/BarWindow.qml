import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 38
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Top

    BarContent {
        parentWindow: root
    }
}
