import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../components"
import "../../session"

ModulePopup {
    id: root

    widthPercent: Theme.popupWidthPercentNarrow
    cardHeight: pwrCol.implicitHeight + Theme.spacingMd * 2

    ColumnLayout {
        id: pwrCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingXs

        Repeater {
            model: [
                { label: "Verrouiller", icon: "󰌾", color: Theme.accent, action: function() { SessionService.lock(); } },
                { label: "Veille", icon: "󰤄", color: Theme.accentSecondary, action: function() { SessionService.suspend(); } },
                { label: "Déconnexion", icon: "󰍃", color: Theme.warning, action: function() { SessionService.logout(); } },
                { label: "Redémarrer", icon: "󰜉", color: Theme.warning, action: function() { SessionService.reboot(); } },
                { label: "Éteindre", icon: "⏻", color: Theme.destructive, action: function() { SessionService.shutdown(); } }
            ]

            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: actMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"
                border.color: actMouse.containsMouse ? Theme.glassBorder : "transparent"
                border.width: 1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: Theme.spacingSm
                        rightMargin: Theme.spacingSm
                    }
                    spacing: Theme.spacingSm

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: modelData.color
                        text: modelData.icon
                    }

                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: modelData.label
                    }
                }

                MouseArea {
                    id: actMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close();
                        modelData.action();
                    }
                }
            }
        }
    }
}
