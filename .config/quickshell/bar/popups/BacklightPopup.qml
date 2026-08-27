import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int brightnessPercent: 100

    cardWidth: 260
    cardHeight: lightCol.implicitHeight + Theme.spacingMd * 2

    function setBrightness(pct) {
        var clamped = Math.max(1, Math.min(100, pct));
        Hyprland.dispatch("hl.dsp.exec_cmd('brightnessctl s " + clamped + "%')");
        root.brightnessPercent = clamped;
    }

    ColumnLayout {
        id: lightCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingMd

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.accent
                text: "󰃠"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Luminosité"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.accent
                text: root.brightnessPercent + "%"
            }
        }

        // Slider interactif
        Rectangle {
            id: lightSliderTrack
            Layout.fillWidth: true
            height: 12
            radius: 6
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: Math.min(parent.width, parent.width * (root.brightnessPercent / 100.0))
                height: parent.height
                radius: 6
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
                    if (wheel.angleDelta.y > 0) {
                        root.setBrightness(Math.min(100, root.brightnessPercent + 5));
                    } else if (wheel.angleDelta.y < 0) {
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
                model: [
                    { label: "10%", pct: 10 },
                    { label: "25%", pct: 25 },
                    { label: "50%", pct: 50 },
                    { label: "75%", pct: 75 },
                    { label: "100%", pct: 100 }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 24
                    radius: Theme.radiusSmall
                    color: bPresetMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Theme.glassBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.textPrimary
                        text: modelData.label
                    }

                    MouseArea {
                        id: bPresetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.setBrightness(modelData.pct);
                        }
                    }
                }
            }
        }
    }
}
