import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int brightnessPercent: 100

    widthPercent: Theme.popupWidthPercentNarrow
    cardHeight: lightCol.implicitHeight + Theme.spacingMd * 2

    function setBrightness(pct) {
        var clamped = Math.max(1, Math.min(100, pct));
        Quickshell.execDetached(["brightnessctl", "s", clamped + "%"]);
        root.brightnessPercent = clamped;
    }

    ColumnLayout {
        id: lightCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.accent
                text: "󰃠"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: "Luminosité"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.accent
                text: root.brightnessPercent + "%"
            }
        }

        // Slider interactif
        Rectangle {
            id: lightSliderTrack
            Layout.fillWidth: true
            height: Theme.spacingXs
            radius: Theme.radiusSmall / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: Math.min(parent.width, parent.width * (root.brightnessPercent / 100.0))
                height: parent.height
                radius: Theme.radiusSmall / 2
                color: Theme.accent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateFromMouse(mouseX) {
                    var pct = Math.round(Math.max(1, Math.min(100, (mouseX / lightSliderTrack.width) * 100)));
                    root.setBrightness(pct);
                }

                onPressed: function(mouse) {
                    updateFromMouse(mouse.x);
                }

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        updateFromMouse(mouse.x);
                    }
                }

                onWheel: function(wheel) {
                    var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : (wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : 0);
                    if (dy > 0) {
                        root.setBrightness(Math.min(100, root.brightnessPercent + 5));
                    } else if (dy < 0) {
                        root.setBrightness(Math.max(1, root.brightnessPercent - 5));
                    }
                }
            }
        }

        // Paliers rapides
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Repeater {
                model: [25, 50, 75, 100]

                delegate: Rectangle {
                    required property int modelData
                    Layout.fillWidth: true
                    height: Theme.spacingLg * 1.4
                    radius: Theme.radiusSmall
                    color: bPresetMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Theme.glassBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold: true
                        color: Theme.textPrimary
                        text: modelData + "%"
                    }

                    MouseArea {
                        id: bPresetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setBrightness(modelData)
                    }
                }
            }
        }
    }
}
