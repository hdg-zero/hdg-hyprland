import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../theme"
import "../"
import "../NotificationGroups.js" as Groups

ColumnLayout {
    id: root

    property var targetScreen: null
    property real maximumHeight: 200
    property var expandedGroups: ({})
    property double now: Date.now()
    readonly property var groups: {
        var notifications = NotificationService.trackedNotifications;
        var values = notifications ? notifications.values : [];
        return Groups.groupNotifications((values || []).filter(function(n) {
            return NotificationService.isValidNotification(n);
        }), NotificationService.receivedAt);
    }
    spacing: Theme.spacingSm

    function toggleGroup(key) {
        var expanded = Object.assign({}, root.expandedGroups);
        expanded[key] = !expanded[key];
        root.expandedGroups = expanded;
    }

    function dismissGroup(group) {
        // Copie stable : chaque dismiss modifie immédiatement le modèle D-Bus.
        group.notifications.slice().forEach(function(notification) {
            NotificationService.dismissNotification(notification);
        });
    }

    function getNotificationActions(item) {
        if (!item || !item.actions) return [];
        if (Array.isArray(item.actions)) return item.actions;
        if (typeof item.actions.values !== "function" && item.actions.values) return item.actions.values;
        if (typeof item.actions.length === "number") return item.actions;
        return [];
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacingXs
        spacing: Theme.spacingSm
        Text {
            font.family: NotificationStyle.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textSecondary
            text: "Notifications"
        }
        Rectangle {
            visible: NotificationService.unreadCount > 0
            implicitWidth: countLabel.implicitWidth + Theme.spacingMd
            implicitHeight: 18
            radius: Theme.radiusSmall
            color: NotificationStyle.activeSurface
            Text {
                id: countLabel
                anchors.centerIn: parent
                font.family: NotificationStyle.fontFamily
                font.pixelSize: Theme.fontSizeMicro
                color: NotificationStyle.accentText
                text: NotificationService.unreadCount.toString()
            }
        }
        Item { Layout.fillWidth: true }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: root.groups.length === 0 ? 32
            : Math.min(root.maximumHeight, groupList.contentHeight)

        Text {
            anchors.centerIn: parent
            visible: root.groups.length === 0
            font.family: NotificationStyle.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textDisabled
            text: "Aucune notification"
        }

        ListView {
            id: groupList
            reuseItems: true
            anchors.fill: parent
            visible: root.groups.length > 0
            model: root.groups
            spacing: Theme.spacingSm
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                id: groupCard
                required property var modelData
                readonly property bool expanded: !!root.expandedGroups[modelData.key]
                width: groupList.width
                implicitHeight: groupColumn.implicitHeight + Theme.spacingXs * 2
                radius: Theme.radiusMedium
                color: NotificationStyle.surface

                ColumnLayout {
                    id: groupColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingXs
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.spacingSm
                        spacing: Theme.spacingXs

                        Button {
                            id: groupToggle
                            Layout.fillWidth: true
                            implicitHeight: 28
                            padding: 0
                            hoverEnabled: true
                            Accessible.name: groupCard.modelData.appName + ", "
                                + groupCard.modelData.notifications.length + " notifications, "
                                + (groupCard.expanded ? "replier" : "déplier")
                            onClicked: root.toggleGroup(groupCard.modelData.key)
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: groupToggle.hovered ? NotificationStyle.hoverSurface : "transparent"
                                border.width: groupToggle.activeFocus ? 1 : 0
                                border.color: NotificationStyle.accent
                            }
                            contentItem: RowLayout {
                                spacing: Theme.spacingSm
                                Item {
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    Image {
                                        id: appIcon
                                        anchors.fill: parent
                                        asynchronous: true
                                        sourceSize: Qt.size(20, 20)
                                        fillMode: Image.PreserveAspectFit
                                        source: groupCard.modelData.appIcon
                                            ? Quickshell.iconPath(groupCard.modelData.appIcon, true) || groupCard.modelData.appIcon : ""
                                        visible: status === Image.Ready
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: !appIcon.visible
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeRegular
                                        color: NotificationStyle.accentText
                                        text: "󰂚"
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    font.family: NotificationStyle.fontFamily
                                    font.pixelSize: Theme.fontSizeMicro
                                    color: Theme.textSecondary
                                    text: groupCard.modelData.appName
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                }
                                Text {
                                    font.family: NotificationStyle.fontFamily
                                    font.pixelSize: Theme.fontSizeMicro
                                    color: Theme.textSecondary
                                    text: groupCard.modelData.notifications.length.toString()
                                }
                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeTiny
                                    color: Theme.textSecondary
                                    text: groupCard.expanded ? "󰅃" : "󰅀"
                                }
                            }
                        }
                        PanelIconButton {
                            implicitWidth: 28
                            implicitHeight: 28
                            glyph: "󰅖"
                            description: "Effacer les notifications de " + groupCard.modelData.appName
                            onClicked: root.dismissGroup(groupCard.modelData)
                        }
                    }

                    Repeater {
                        model: groupCard.expanded ? groupCard.modelData.notifications
                            : groupCard.modelData.notifications.slice(0, 1)

                        delegate: ColumnLayout {
                            id: notificationItem
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.spacingSm
                            Layout.rightMargin: Theme.spacingSm
                            Layout.bottomMargin: Theme.spacingSm
                            spacing: Theme.spacingXs

                            Rectangle {
                                visible: notificationItem.index > 0
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: NotificationStyle.border
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingXs
                                Text {
                                    Layout.fillWidth: true
                                    font.family: NotificationStyle.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.DemiBold
                                    color: Theme.textPrimary
                                    text: notificationItem.modelData.summary || ""
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                }
                                Text {
                                    font.family: NotificationStyle.fontFamily
                                    font.pixelSize: Theme.fontSizeMicro
                                    color: Theme.textSecondary
                                    text: Groups.relativeTime(NotificationService.receivedAt[notificationItem.modelData.id], root.now)
                                }
                                PanelIconButton {
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    glyph: "󰅖"
                                    description: "Supprimer cette notification"
                                    onClicked: NotificationService.dismissNotification(notificationItem.modelData)
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                font.family: NotificationStyle.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                color: Theme.textSecondary
                                text: notificationItem.modelData.body || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                            Flow {
                                Layout.fillWidth: true
                                visible: actionRepeater.count > 0
                                spacing: Theme.spacingXs
                                Repeater {
                                    id: actionRepeater
                                    model: root.getNotificationActions(notificationItem.modelData)
                                    delegate: Button {
                                        id: actionButton
                                        required property var modelData
                                        text: modelData.text || "Action"
                                        width: Math.min(implicitWidth, parent.width)
                                        implicitHeight: 26
                                        leftPadding: Theme.spacingSm
                                        rightPadding: Theme.spacingSm
                                        Accessible.name: text
                                        background: Rectangle {
                                            radius: Theme.radiusSmall
                                            color: actionButton.hovered ? NotificationStyle.hoverSurface : NotificationStyle.activeSurface
                                            border.width: actionButton.activeFocus ? 1 : 0
                                            border.color: NotificationStyle.accent
                                        }
                                        contentItem: Text {
                                            text: actionButton.text
                                            textFormat: Text.PlainText
                                            font.family: NotificationStyle.fontFamily
                                            font.pixelSize: Theme.fontSizeMicro
                                            color: NotificationStyle.accentText
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        // invoke() ferme les notifications non résidentes.
                                        onClicked: {
                                            if (modelData && typeof modelData.invoke === "function") modelData.invoke();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
