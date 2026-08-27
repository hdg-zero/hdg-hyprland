import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    cardWidth: 240
    cardHeight: pwrCol.implicitHeight + Theme.spacingMd * 2

    ColumnLayout {
        id: pwrCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.destructive
                text: "⏻"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Session & Énergie"
            }
        }

        // Séparateur
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
            Layout.topMargin: Theme.spacingXs
            Layout.bottomMargin: Theme.spacingXs
        }

        // Actions
        Repeater {
            model: [
                { label: "Verrouiller", icon: "󰌾", color: Theme.accent, cmd: "hyprlock" },
                { label: "Mettre en veille", icon: "󰤄", color: Theme.accentSecondary, cmd: "systemctl suspend" },
                { label: "Déconnexion", icon: "󰍃", color: Theme.warning, cmd: "hyprctl dispatch exit" },
                { label: "Redémarrer", icon: "󰜉", color: Theme.warning, cmd: "systemctl reboot" },
                { label: "Éteindre", icon: "⏻", color: Theme.destructive, cmd: "systemctl poweroff" }
            ]

            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 32
                radius: Theme.radiusMedium
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
                        font.pixelSize: Theme.fontSizeMedium
                        color: modelData.color
                        text: modelData.icon
                    }

                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textPrimary
                        text: modelData.label
                    }

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textDisabled
                        text: "󰅂"
                    }
                }

                MouseArea {
                    id: actMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["sh", "-c", modelData.cmd]);
                        root.close();
                    }
                }
            }
        }
    }
}
