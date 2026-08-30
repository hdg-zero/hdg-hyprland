import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Notifications as Notifs
import "../theme"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData

    anchors {
        top: true
        right: true
    }

    margins {
        top: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + Theme.spacingSm)
        right: Theme.spacingMd
    }

    implicitWidth: Theme.notificationToastWidth
    implicitHeight: toastCol.implicitHeight

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    visible: NotificationService.activeToasts.length > 0

    function getNotificationActions(n) {
        if (!n || !n.actions) return [];
        if (Array.isArray(n.actions)) return n.actions;
        if (typeof n.actions.values !== "function" && n.actions.values) return n.actions.values;
        if (typeof n.actions.length === "number") return n.actions;
        return [];
    }

    ColumnLayout {
        id: toastCol
        width: parent.width
        spacing: Theme.spacingSm

        Repeater {
            model: NotificationService.activeToasts

            delegate: Rectangle {
                id: toastCard
                required property var modelData
                readonly property var notif: modelData.notification
                readonly property bool isCritical: notif && notif.urgency === Notifs.NotificationUrgency.Critical
                readonly property bool isHovered: cardMouse.containsMouse

                Layout.fillWidth: true
                implicitHeight: cardLayout.implicitHeight + Theme.spacingSm * 2 + 3
                radius: Theme.radiusMedium
                color: Theme.cardBackgroundSolid
                border.color: isCritical ? Theme.destructive : Theme.glassBorder
                border.width: 1
                clip: true

                // Animation d'apparition
                opacity: 1.0
                scale: 1.0
                Behavior on opacity { NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType } }
                Behavior on scale { NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType } }

                // Timer d'expiration automatique
                Timer {
                    id: dismissTimer
                    interval: modelData.timeout
                    running: modelData.timeout > 0 && !toastCard.isHovered
                    repeat: false
                    onTriggered: {
                        NotificationService.dismissToast(toastCard.modelData.id);
                    }
                }

                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                ColumnLayout {
                    id: cardLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacingSm
                    }
                    spacing: Theme.spacingXs

                    // En-tête : Icône, Nom de l'app, bouton fermer
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        IconImage {
                            id: toastAppIcon
                            width: 16
                            height: 16
                            source: {
                                if (!toastCard.notif) return "";
                                if (toastCard.notif.appIcon) {
                                    return Quickshell.iconPath(toastCard.notif.appIcon, true) || toastCard.notif.appIcon;
                                }
                                if (toastCard.notif.image) {
                                    return toastCard.notif.image;
                                }
                                return "";
                            }
                            visible: source !== "" && status === Image.Ready
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: toastCard.isCritical ? Theme.destructive : Theme.accent
                            text: "󰂚"
                            visible: !toastAppIcon.visible
                        }

                        Text {
                            Layout.fillWidth: true
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: toastCard.isCritical ? Theme.destructive : Theme.accent
                            text: toastCard.notif ? (toastCard.notif.appName || "Notification") : "Notification"
                            elide: Text.ElideRight
                        }

                        // Bouton fermer le toast
                        Rectangle {
                            width: 20
                            height: 20
                            radius: width / 2
                            color: closeMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                color: closeMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                                text: "󰅖"
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NotificationService.dismissToast(toastCard.modelData.id);
                                }
                            }
                        }
                    }

                    // Titre (Summary)
                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeRegular
                        font.bold: true
                        color: Theme.textPrimary
                        text: toastCard.notif ? (toastCard.notif.summary || "") : ""
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Corps du message (Body)
                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                        text: toastCard.notif ? (toastCard.notif.body || "") : ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Actions de la notification (si présentes)
                    RowLayout {
                        Layout.fillWidth: true
                        visible: root.getNotificationActions(toastCard.notif).length > 0
                        spacing: Theme.spacingXs

                        Repeater {
                            model: root.getNotificationActions(toastCard.notif)

                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: actionText.implicitWidth + Theme.spacingSm * 2
                                implicitHeight: 22
                                radius: Theme.radiusSmall
                                color: actionMouse.containsMouse ? Theme.accent : Theme.cardBackgroundHover
                                border.color: Theme.glassBorder
                                border.width: 1

                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeTiny
                                    font.bold: true
                                    color: actionMouse.containsMouse ? Theme.backgroundSolid : Theme.textPrimary
                                    text: modelData.text || "Action"
                                }

                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData && typeof modelData.invoke === "function") {
                                            modelData.invoke();
                                        }
                                        NotificationService.dismissToast(toastCard.modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }

                // Barre de progression du temps d'affichage
                Rectangle {
                    id: progressTrack
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: 2
                    color: Qt.rgba(1, 1, 1, 0.05)
                    visible: modelData.timeout > 0

                    Rectangle {
                        id: progressBar
                        height: parent.height
                        width: parent.width
                        color: toastCard.isCritical ? Theme.destructive : Theme.accent

                        NumberAnimation on width {
                            from: progressTrack.width
                            to: 0
                            duration: modelData.timeout > 0 ? modelData.timeout : 1
                            running: modelData.timeout > 0 && !toastCard.isHovered
                        }
                    }
                }
            }
        }
    }
}
