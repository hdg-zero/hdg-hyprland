import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int volumePercent: 50
    property bool isMuted: false
    property bool isBluetooth: false

    cardWidth: 190
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
        spacing: Theme.spacingSm

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: root.isMuted ? Theme.destructive : Theme.accent
                text: root.isMuted ? (root.isBluetooth ? "󰂲" : "󰝟") : (root.isBluetooth ? "󰂯" : "󰕾")
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.isBluetooth ? "Bluetooth" : "Volume"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.isMuted ? Theme.destructive : (root.volumePercent > 100 ? Theme.warning : Theme.accent)
                text: root.isMuted ? "Muet" : root.volumePercent + "%"
            }
        }

        // Slider interactif
        Rectangle {
            id: sliderTrack
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: Math.min(parent.width, parent.width * (root.volumePercent / 150.0))
                height: parent.height
                radius: 3
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

        // Actions rapides compactes
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            // Bouton Mute
            Rectangle {
                Layout.fillWidth: true
                height: 24
                radius: Theme.radiusSmall
                color: muteMouse.containsMouse ? Theme.cardBackgroundHover : (root.isMuted ? Qt.rgba(0.95, 0.54, 0.66, 0.2) : Qt.rgba(1, 1, 1, 0.05))
                border.color: root.isMuted ? Theme.destructive : Theme.glassBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: root.isMuted ? Theme.destructive : Theme.textPrimary
                    text: root.isMuted ? "󰝟 Muet" : "󰕾 Mute"
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute()
                }
            }

            // Bouton Pavucontrol
            Rectangle {
                width: 28
                height: 24
                radius: Theme.radiusSmall
                color: pavuMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: Theme.glassBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.accent
                    text: "󰓃"
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
