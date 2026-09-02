import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"
import "../caffeine"

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
    exclusiveZone: implicitHeight
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-bar"

    // Inhibiteur d'inactivité Wayland natif lié au mode caféine
    IdleInhibitor {
        window: root
        enabled: CaffeineService.active
    }

    BarContent {
        parentWindow: root
        implicitHeight: root.implicitHeight
    }
}
