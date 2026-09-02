import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../components"
import "../../caffeine"

ModulePopup {
    id: root

    widthPercent: Theme.popupWidthPercentNarrow
    cardHeight: contentCol.implicitHeight + Theme.spacingMd * 2

    ColumnLayout {
        id: contentCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête avec icône et titre
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: CaffeineService.active ? Theme.accent : Theme.textDisabled
                text: CaffeineService.active ? "󰅶" : "󰾪"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Mode Caféine"
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    color: CaffeineService.active ? Theme.accent : Theme.textSecondary
                    text: CaffeineService.active ? "Anti-sommeil actif" : "Inactif (sommeil normal)"
                }
            }
        }

        // Séparateur subtil
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorderSubtle
        }

        // Description concise
        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMicro
            color: Theme.textSecondary
            text: CaffeineService.active
                ? "L'extinction d'écran, le verrouillage et la mise en veille automatique sont suspendus."
                : "La gestion d'énergie automatique de Hypridle est active."
        }

        // Bouton d'action de bascule
        Rectangle {
            Layout.fillWidth: true
            height: 34
            radius: Theme.radiusSmall
            color: CaffeineService.active ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : (toggleMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.08))
            border.color: CaffeineService.active ? Theme.accent : Theme.glassBorderSubtle
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingSm

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: CaffeineService.active ? Theme.accent : Theme.textPrimary
                    text: CaffeineService.active ? "󰅶" : "󰾪"
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    font.bold: true
                    color: CaffeineService.active ? Theme.accent : Theme.textPrimary
                    text: CaffeineService.active ? "Désactiver le mode" : "Activer le mode"
                }
            }

            MouseArea {
                id: toggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    CaffeineService.toggle();
                }
            }
        }
    }
}
