import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null
    property bool autoHover: true
    property bool isOpen: false
    
    property real widthPercent: 0
    property alias cardWidth: card.implicitWidth
    property alias cardHeight: card.implicitHeight
    default property alias content: innerContainer.data

    readonly property bool isHovered: (anchorItem && anchorItem.isHovered) || cardHoverHandler.hovered

    readonly property real effectiveWidth: {
        if (widthPercent > 0) {
            return Theme.relWidth(widthPercent, parentWindow ? parentWindow.screen : null);
        }
        return card.implicitWidth > 0 ? card.implicitWidth : Theme.relWidth(Theme.popupWidthPercentCompact, parentWindow ? parentWindow.screen : null);
    }

    anchor.window: parentWindow
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Math.max(4, Theme.relHeight(Theme.barMarginTopRatio, parentWindow ? parentWindow.screen : null))

    color: "transparent"
    visible: false

    implicitWidth: effectiveWidth
    implicitHeight: card.implicitHeight

    function toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }

    function open() {
        isOpen = true;
        visible = true;
    }

    function close() {
        isOpen = false;
    }

    Timer {
        id: hoverOpenTimer
        interval: 140
        repeat: false
        onTriggered: {
            if (root.autoHover && root.anchorItem && root.anchorItem.isHovered) {
                root.open();
            }
        }
    }

    Timer {
        id: hoverCloseTimer
        interval: 320
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
                if (!cardHoverHandler.hovered) {
                    hoverCloseTimer.restart();
                }
            }
        }
    }

    GlassCard {
        id: card
        anchors.fill: parent
        customColor: Qt.rgba(0.094, 0.094, 0.145, 0.95)
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusLarge

        opacity: root.isOpen ? 1.0 : 0.0
        scale: root.isOpen ? 1.0 : 0.95
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animDurationFast
                easing.type: Theme.easingType
                onRunningChanged: {
                    if (!running && !root.isOpen) {
                        root.visible = false;
                    }
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animDurationFast
                easing.type: Theme.easingType
            }
        }

        HoverHandler {
            id: cardHoverHandler
            onHoveredChanged: {
                if (hovered) {
                    hoverCloseTimer.stop();
                } else {
                    if (root.autoHover && (!root.anchorItem || !root.anchorItem.isHovered)) {
                        hoverCloseTimer.restart();
                    }
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
