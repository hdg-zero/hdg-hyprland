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

        // En-tête avec icône et titre épuré
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: CaffeineService.active ? Theme.accent : Theme.textDisabled
                text: CaffeineService.active ? "󰅶" : "󰾪"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: "Mode Caféine"
            }
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
