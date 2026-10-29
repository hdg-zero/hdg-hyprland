import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../theme"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null
    property bool isOpen: false
    property bool pinned: false
    property real cardWidth: 260
    property real cardHeight: 0
    property real contentHeight: cardHeight
    property int contentPadding: PopupStyle.padding
    property bool keepAspectRatio: false
    property real popupX: 0
    property real popupY: 0
    property bool closedNotified: false
    default property alias content: innerContainer.data
    signal fullyClosed()

    readonly property bool isHovered: (anchorItem && anchorItem.isHovered) || cardHover.hovered
    readonly property real availableWidth: Math.max(1,
        (parentWindow && parentWindow.screen ? parentWindow.screen.width : 1920) - 24)
    readonly property real maximumHeight: Math.max(1,
        (parentWindow && parentWindow.screen ? parentWindow.screen.height : 1080)
        - Theme.relHeight(Theme.barHeightRatio, parentWindow ? parentWindow.screen : null) - 32)
    readonly property real geometryScale: keepAspectRatio
        ? Math.min(1, availableWidth / Math.max(1, cardWidth), maximumHeight / Math.max(1, cardHeight)) : 1
    readonly property int effectiveWidth: Math.max(1, Math.floor(keepAspectRatio
        ? cardWidth * geometryScale : Math.min(cardWidth, availableWidth)))

    anchor.window: parentWindow
    anchor.rect.x: popupX
    anchor.rect.y: popupY
    anchor.rect.width: 1
    anchor.rect.height: 1
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.ResizeY
    anchor.onAnchoring: updatePlacement()
    color: "transparent"
    visible: isOpen || card.opacity > 0
    implicitWidth: effectiveWidth
    implicitHeight: keepAspectRatio ? Math.max(1, Math.floor(cardHeight * geometryScale))
        : Math.min(Math.ceil(cardHeight), maximumHeight)

    function updatePlacement() {
        if (!anchorItem || !parentWindow) return;
        var point = anchorItem.mapToItem(parentWindow.contentItem, anchorItem.width / 2, anchorItem.height);
        popupX = Math.max(12, Math.min(parentWindow.width - effectiveWidth - 12, point.x - effectiveWidth / 2));
        popupY = point.y + Theme.spacingSm;
    }
    function open() {
        closedNotified = false;
        isOpen = true;
        updatePlacement();
        PopupState.registerPopup(root);
        Qt.callLater(syncFocus);
    }
    function close() {
        isOpen = false;
        focusGrab.active = false;
        if (card.opacity <= 0 && !opacityAnimation.running) Qt.callLater(finishClose);
    }
    function toggle() { if (isOpen) close(); else open(); }
    function syncFocus() { focusGrab.active = isOpen && pinned; }
    function finishClose() {
        if (isOpen || closedNotified || card.opacity > 0) return;
        closedNotified = true;
        PopupState.unregisterPopup(root);
        fullyClosed();
    }
    onPinnedChanged: Qt.callLater(syncFocus)
    Component.onDestruction: PopupState.unregisterPopup(root)

    HyprlandFocusGrab {
        id: focusGrab
        windows: root.parentWindow ? [root, root.parentWindow] : [root]
        onCleared: { if (root.isOpen && root.pinned) root.close(); }
    }
    Shortcut { sequence: "Escape"; enabled: root.isOpen && root.pinned; onActivated: root.close() }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: PopupStyle.radius
        border.width: 1
        border.color: PopupStyle.border
        gradient: Gradient {
            GradientStop { position: 0; color: "#f516202a" }
            GradientStop { position: 1; color: "#fa0b0f14" }
        }
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.98
        transformOrigin: Item.Top
        clip: true
        Behavior on opacity {
            NumberAnimation {
                id: opacityAnimation
                duration: 150
                easing.type: Easing.OutCubic
                onRunningChanged: { if (!running) root.finishClose(); }
            }
        }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        HoverHandler { id: cardHover }
        Flickable {
            id: scroller
            anchors.fill: parent
            anchors.margins: root.contentPadding
            contentWidth: width
            contentHeight: innerContainer.height
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Item {
                id: innerContainer
                width: scroller.width
                height: Math.max(0, root.contentHeight - root.contentPadding * 2)
            }
        }
    }
}
