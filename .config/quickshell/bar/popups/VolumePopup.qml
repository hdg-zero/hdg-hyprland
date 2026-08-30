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

    widthPercent: Theme.popupWidthPercentCompact
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
                font.pixelSize: Theme.fontSizeHeader
                color: root.isMuted ? Theme.destructive : Theme.accent
                text: root.isMuted ? (root.isBluetooth ? "󰂲" : "󰝟") : (root.isBluetooth ? "󰂯" : "󰕾")
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: root.isBluetooth ? "Bluetooth" : "Volume"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                font.bold: true
                color: root.isMuted ? Theme.destructive : (root.volumePercent > 100 ? Theme.warning : Theme.accent)
                text: root.isMuted ? "Muet" : root.volumePercent + "%"
            }
        }

        // Slider interactif (plus épais)
        Rectangle {
            id: sliderTrack
            Layout.fillWidth: true
            height: Theme.progressBarHeight
            radius: Theme.progressBarHeight / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: Math.min(parent.width, parent.width * (root.volumePercent / 150.0))
                height: parent.height
                radius: Theme.progressBarHeight / 2
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
                    var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : (wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : 0);
                    if (dy > 0) {
                        root.setVolume(Math.min(150, root.volumePercent + 5));
                    } else if (dy < 0) {
                        root.setVolume(Math.max(0, root.volumePercent - 5));
                    }
                }
            }
        }

        // Actions rapides (Boutons Mute et Panneau de taille égale)
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Bouton Mute (50% largeur)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
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
                        text: root.isMuted ? "Muet" : "Mute"
                    }
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute()
                }
            }

            // Bouton Panneau Pavucontrol (50% largeur)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: pavuMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: pavuMouse.containsMouse ? Theme.glassBorder : Theme.glassBorder
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
                        text: "Panneau"
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
