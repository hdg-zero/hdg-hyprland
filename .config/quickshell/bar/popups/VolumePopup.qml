import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int volumePercent: 50
    property bool isMuted: false
    property bool isBluetooth: false

    cardWidth: 280
    cardHeight: volCol.implicitHeight + Theme.spacingMd * 2

    function setVolume(pct) {
        var frac = (pct / 100.0).toFixed(2);
        Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", frac]);
    }

    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    ColumnLayout {
        id: volCol
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
                color: root.isMuted ? Theme.destructive : Theme.accent
                text: root.isMuted ? (root.isBluetooth ? "󰂲" : "󰝟") : (root.isBluetooth ? "󰂯" : "󰕾")
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: root.isBluetooth ? "Audio Bluetooth" : "Sortie Audio"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: root.isMuted ? Theme.destructive : (root.volumePercent > 100 ? Theme.warning : Theme.accent)
                text: root.isMuted ? "Muet" : root.volumePercent + "%"
            }
        }

        // Slider interactif
        Rectangle {
            id: sliderTrack
            Layout.fillWidth: true
            height: 12
            radius: 6
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: Math.min(parent.width, parent.width * (root.volumePercent / 150.0))
                height: parent.height
                radius: 6
                color: root.isMuted ? Theme.destructive : (root.volumePercent > 100 ? Theme.warning : Theme.accent)
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateFromMouse(mouseX) {
                    var pct = Math.round(Math.max(0, Math.min(150, (mouseX / sliderTrack.width) * 150)));
                    root.setVolume(pct);
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
                        root.setVolume(Math.min(150, root.volumePercent + 5));
                    } else if (wheel.angleDelta.y < 0) {
                        root.setVolume(Math.max(0, root.volumePercent - 5));
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
                    { label: "0%", pct: 0 },
                    { label: "25%", pct: 25 },
                    { label: "50%", pct: 50 },
                    { label: "75%", pct: 75 },
                    { label: "100%", pct: 100 },
                    { label: "150%", pct: 150 }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 24
                    radius: Theme.radiusSmall
                    color: presetMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
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
                        id: presetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.setVolume(modelData.pct);
                        }
                    }
                }
            }
        }

        // Séparateur
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Boutons Muet + Pavucontrol
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Bouton Mute
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: Theme.radiusMedium
                color: muteMouse.containsMouse ? Theme.cardBackgroundHover : (root.isMuted ? Qt.rgba(0.95, 0.54, 0.66, 0.2) : Qt.rgba(1, 1, 1, 0.05))
                border.color: root.isMuted ? Theme.destructive : Theme.glassBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.isMuted ? Theme.destructive : Theme.textPrimary
                        text: root.isMuted ? "󰝟" : "󰕾"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.isMuted ? Theme.destructive : Theme.textPrimary
                        text: root.isMuted ? "Rétablir" : "Couper"
                    }
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.toggleMute();
                    }
                }
            }

            // Bouton Pavucontrol
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: Theme.radiusMedium
                color: pavuMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: Theme.glassBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accent
                        text: "󰓃"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: "Mixeur Audio"
                    }
                }

                MouseArea {
                    id: pavuMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["pavucontrol", "-t", "3"]);
                        root.close();
                    }
                }
            }
        }
    }
}
