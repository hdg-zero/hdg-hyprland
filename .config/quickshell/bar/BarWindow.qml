import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"

PanelWindow {
    id: root

    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Math.max(24, Theme.relHeight(Theme.barHeightRatio, root.screen))

    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: implicitHeight

    BarContent {
        parentWindow: root
    }
}
