import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null
    property bool autoHover: true
    
    property alias cardWidth: card.implicitWidth
    property alias cardHeight: card.implicitHeight
    default property alias content: innerContainer.data

    readonly property bool isHovered: (anchorItem && anchorItem.isHovered) || cardMouse.containsMouse

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

    Timer {
        id: hoverOpenTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (root.autoHover && root.anchorItem && root.anchorItem.isHovered) {
                root.open();
            }
        }
    }

    Timer {
        id: hoverCloseTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (root.autoHover && !root.isHovered) {
                root.close();
            }
        }
    }

    Connections {
        target: root.anchorItem
        ignoreUnknownSignals: true
        function onEntered() {
            if (root.autoHover) {
                hoverCloseTimer.stop();
                hoverOpenTimer.restart();
            }
        }
        function onExited() {
            if (root.autoHover) {
                hoverOpenTimer.stop();
                hoverCloseTimer.restart();
            }
        }
    }

    GlassCard {
        id: card
        anchors.fill: parent
        customColor: Qt.rgba(0.094, 0.094, 0.145, 0.95)
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusLarge

        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                hoverCloseTimer.stop();
            }
            onExited: {
                if (root.autoHover) {
                    hoverCloseTimer.restart();
                }
            }
        }

        Item {
            id: innerContainer
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
        }
    }
}
