import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null
    
    property alias cardWidth: card.implicitWidth
    property alias cardHeight: card.implicitHeight
    default property alias content: innerContainer.data

    anchor.window: parentWindow
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 6

    color: "transparent"
    visible: false

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    function toggle() {
        visible = !visible;
    }

    function open() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    GlassCard {
        id: card
        anchors.fill: parent
        customColor: Qt.rgba(0.094, 0.094, 0.145, 0.95)
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusLarge

        Item {
            id: innerContainer
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
        }
    }
}
