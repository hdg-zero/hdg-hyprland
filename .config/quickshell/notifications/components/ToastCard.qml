import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications as Notifs
import "../../theme"
import "../../components"
import ".."
import "../NotificationGroups.js" as Groups

Rectangle {
    id: root
    required property var toast
    readonly property var notif: toast ? toast.notification : null
    readonly property var lifetime: toast ? toast.lifetime : null
    readonly property bool critical: notif && notif.urgency === Notifs.NotificationUrgency.Critical
    property double now: Date.now()
    property bool entered: false
    readonly property var actions: {
        if (!notif || !notif.actions) return [];
        return notif.actions.values && typeof notif.actions.values !== "function" ? notif.actions.values : notif.actions;
    }
    implicitHeight: content.implicitHeight + 32
    radius: PopupStyle.radius
    border.width: 1
    border.color: PopupStyle.border
    clip: true
    opacity: entered && !(lifetime && lifetime.finishing) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Component.onCompleted: entered = true
    gradient: Gradient {
        GradientStop { position: 0; color: "#f516202a" }
        GradientStop { position: 1; color: "#fa0b0f14" }
    }
    HoverHandler {
        id: hover
        onHoveredChanged: { if (root.lifetime && !root.lifetime.stopped) root.lifetime.paused = hovered; }
    }
    Component.onDestruction: { if (lifetime && !lifetime.stopped) lifetime.paused = false; }
    Timer { interval: 60000; running: root.visible; repeat: true; onTriggered: root.now = Date.now() }
    Rectangle {
        visible: root.critical
        width: 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        color: PopupStyle.warning
        radius: 1
    }
    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            IconImage {
                id: appIcon
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                source: !root.notif ? "" : root.notif.appIcon
                    ? Quickshell.iconPath(root.notif.appIcon, true) || root.notif.appIcon : root.notif.image || ""
                visible: source.toString() !== "" && status === Image.Ready
            }
            PopupGlyph { visible: !appIcon.visible; text: "󰂚"; font.pixelSize: 16; color: root.critical ? PopupStyle.warning : PopupStyle.accentText }
            PopupText { Layout.fillWidth: true; text: root.notif ? root.notif.appName || "Notification" : "Notification"; font.pixelSize: 11; color: Theme.textSecondary }
            PopupText { text: root.toast ? Groups.relativeTime(root.toast.createdAt, root.now) : ""; font.pixelSize: 10; color: Theme.textDisabled }
            PopupIconButton { implicitWidth: 24; implicitHeight: 24; glyph: "󰅖"; description: "Masquer la notification"; onClicked: NotificationService.dismissToast(root.toast.id) }
        }
        PopupText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.notif ? root.notif.summary || "" : ""
            font.pixelSize: 14
            font.weight: Font.DemiBold
            wrapMode: Text.Wrap
            maximumLineCount: 2
        }
        PopupText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.notif ? root.notif.body || "" : ""
            textFormat: Text.StyledText
            font.pixelSize: 12
            color: Theme.textSecondary
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }
        Flow {
            Layout.fillWidth: true
            visible: root.actions.length > 0
            spacing: 6
            Repeater {
                model: root.actions
                delegate: Button {
                    id: actionButton
                    required property var modelData
                    width: Math.min(implicitWidth, parent.width)
                    implicitHeight: 28
                    leftPadding: 10
                    rightPadding: 10
                    focusPolicy: Qt.StrongFocus
                    Accessible.name: modelData.text || "Action"
                    contentItem: PopupText { text: actionButton.modelData.text || "Action"; font.pixelSize: 11; verticalAlignment: Text.AlignVCenter; color: PopupStyle.accentText }
                    background: Rectangle { radius: 8; color: actionButton.hovered ? PopupStyle.hoverSurface : PopupStyle.activeSurface; border.width: 1; border.color: actionButton.visualFocus ? PopupStyle.accent : PopupStyle.activeBorder }
                    onClicked: { if (modelData && typeof modelData.invoke === "function") modelData.invoke(); }
                }
            }
        }
    }
    Rectangle {
        visible: root.lifetime && root.lifetime.durationMs > 0
        height: 1
        anchors.bottom: parent.bottom
        x: 16
        width: root.lifetime ? Math.max(0, parent.width - 32) * root.lifetime.remainingMs / Math.max(1, root.lifetime.durationMs) : 0
        color: PopupStyle.accent
        opacity: 0.6
    }
}
