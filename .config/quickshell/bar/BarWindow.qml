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

    margins {
        top: Math.max(4, Theme.relHeight(Theme.barMarginTopRatio, root.screen))
        left: Math.max(6, Theme.relWidth(Theme.barMarginSideRatio, root.screen))
        right: Math.max(6, Theme.relWidth(Theme.barMarginSideRatio, root.screen))
        bottom: Math.max(4, Theme.relHeight(Theme.barMarginTopRatio, root.screen))
    }

    height: Math.max(34, Theme.relHeight(Theme.barHeightRatio, root.screen))
    implicitHeight: height

    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: height + margins.top + margins.bottom

    BarContent {
        parentWindow: root
    }
}
