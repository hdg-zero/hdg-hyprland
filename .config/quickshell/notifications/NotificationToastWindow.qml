import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "components"

PanelWindow {
    id: root
    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData
    anchors { top: true; right: true }
    readonly property var popup: PopupState.currentPopup
    readonly property real baseTop: Theme.relHeight(Theme.barHeightRatio, screen) + 8
    readonly property bool overlapsPopup: popup && popup.visible && popup.parentWindow
        && popup.parentWindow.screen === root.screen
        && popup.popupX + popup.implicitWidth > root.screen.width - implicitWidth - 12
    readonly property bool placeOnLeft: overlapsPopup && popup.popupX >= implicitWidth + 24
    margins.right: placeOnLeft ? Math.max(12, screen.width - implicitWidth - 12) : 12
    margins.top: overlapsPopup && !placeOnLeft ? popup.popupY + popup.implicitHeight + 8 : baseTop
    implicitWidth: Math.max(1, Math.min(380, screen ? screen.width - 24 : 380))
    implicitHeight: Math.max(1, Math.min(toastColumn.implicitHeight,
        (screen ? screen.height : 1080) - margins.top - 12))
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    visible: NotificationService.activeToasts.length > 0

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: toastColumn.implicitHeight
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Column {
            id: toastColumn
            width: parent.width
            spacing: 8
            Repeater {
                model: NotificationService.activeToasts
                delegate: ToastCard {
                    required property var modelData
                    toast: modelData
                    width: toastColumn.width
                }
            }
        }
    }
}
