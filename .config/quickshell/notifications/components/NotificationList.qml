import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../"

ColumnLayout {
    id: root

    property var targetScreen: null
    spacing: Theme.spacingSm

    function getNotificationActions(item) {
        if (!item || !item.actions) return [];
        if (Array.isArray(item.actions)) return item.actions;
        if (typeof item.actions.values !== "function" && item.actions.values) return item.actions.values;
        if (typeof item.actions.length === "number") return item.actions;
        return [];
    }

    // En-tête : Titre + Badge de compteur
    RowLayout {
        Layout.fillWidth: true

        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textSecondary
            text: "Notifications"
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            visible: NotificationService.unreadCount > 0
            width: Math.round(Theme.fontSizeLarge)
            height: width
            radius: width / 2
            color: Theme.accent

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMicro
                font.bold: true
                color: Theme.backgroundSolid
                text: NotificationService.unreadCount.toString()
            }
        }
    }

    // Liste défilante des notifications
    Item {
        Layout.fillWidth: true
        implicitHeight: NotificationService.unreadCount === 0 ? 32 : Math.min(280, Math.max(60, notifList.contentHeight))
        clip: true

        // État vide minimaliste
        ColumnLayout {
            anchors.centerIn: parent
            visible: NotificationService.unreadCount === 0
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDisabled
                text: "Aucune notification"
            }
        }

        // Vue Liste
        ListView {
            id: notifList
            anchors.fill: parent
            visible: NotificationService.unreadCount > 0
            boundsBehavior: Flickable.StopAtBounds
            model: {
                if (!NotificationService.trackedNotifications || !NotificationService.trackedNotifications.values) return [];
                return NotificationService.trackedNotifications.values.filter(function(n) {
                    return n && ((n.summary || "").trim() !== "" || (n.body || "").trim() !== "");
                });
            }
            clip: true
            spacing: Theme.spacingSm

            delegate: Rectangle {
                id: notifCard
                required property var modelData
                width: notifList.width
                implicitHeight: cardInnerCol.implicitHeight + Theme.spacingMd * 2
                radius: Theme.radiusLarge
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: cardHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                MouseArea {
                    id: cardHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                ColumnLayout {
                    id: cardInnerCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacingMd
                    }
                    spacing: Theme.spacingXs

                    // En-tête de la notification
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.accent
                            text: modelData.appName || "Application"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: Math.round(Theme.fontSizeLarge)
                            height: width
                            radius: width / 2
                            color: itemDelMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.3) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                color: itemDelMouse.containsMouse ? Theme.destructive : Theme.textDisabled
                                text: "󰅖"
                            }

                            MouseArea {
                                id: itemDelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NotificationService.dismissNotification(modelData);
                                }
                            }
                        }
                    }

                    // Titre
                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textPrimary
                        text: modelData.summary || ""
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Corps
                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                        text: modelData.body || ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Boutons d'actions
                    RowLayout {
                        Layout.fillWidth: true
                        visible: root.getNotificationActions(modelData).length > 0
                        spacing: Theme.spacingSm
                        Layout.topMargin: Theme.spacingXs

                        Repeater {
                            model: root.getNotificationActions(modelData)

                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: actLabel.implicitWidth + Theme.spacingMd * 2
                                implicitHeight: 24
                                radius: Theme.radiusSmall
                                color: actBtnMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                border.width: 1

                                Text {
                                    id: actLabel
                                    anchors.centerIn: parent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeTiny
                                    font.bold: true
                                    color: actBtnMouse.containsMouse ? Theme.backgroundSolid : Theme.textPrimary
                                    text: modelData.text || "Action"
                                }

                                MouseArea {
                                    id: actBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData && typeof modelData.invoke === "function") {
                                            modelData.invoke();
                                        }
                                        NotificationService.dismissNotification(notifCard.modelData);
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
