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

    height: Math.max(28, Theme.relHeight(Theme.barHeightRatio, root.screen))
    implicitHeight: height

    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: height

    BarContent {
        parentWindow: root
    }
}
