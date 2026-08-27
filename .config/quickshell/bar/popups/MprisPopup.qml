import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    cardWidth: 320
    cardHeight: mprisCol.implicitHeight + Theme.spacingMd * 2

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool isPlaying: player ? (player.playbackState === MprisPlaybackState.Playing) : false

    ColumnLayout {
        id: mprisCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingMd

        // Pochette et Infos
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd

            // Pochette d'album
            Rectangle {
                width: 72
                height: 72
                radius: Theme.radiusMedium
                color: Qt.rgba(1, 1, 1, 0.05)
                clip: true
                border.color: Theme.glassBorder
                border.width: 1

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: root.player ? (root.player.trackArtUrl || root.player.artUrl || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source !== "" && status === Image.Ready
                    smooth: true
                    asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: !albumArt.visible
                    font.family: Theme.fontFamily
                    font.pixelSize: 28
                    color: Theme.textDisabled
                    text: "󰝚"
                }
            }

            // Textes : Titre, Artiste, Album
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.player ? (root.player.trackTitle || "Aucune lecture") : "Aucun lecteur"
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.accent
                    text: root.player ? (root.player.trackArtist || "Artiste inconnu") : ""
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textSecondary
                    text: root.player ? (root.player.trackAlbum || (root.player.identity || "")) : ""
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }
        }

        // Séparateur
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Contrôles multimédia
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingMd

            // Précédent
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: prevMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: root.player ? Theme.textPrimary : Theme.textDisabled
                    text: "󰒮"
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player) root.player.previous();
                    }
                }
            }

            // Lecture / Pause (Grand bouton rond)
            Rectangle {
                width: 42
                height: 42
                radius: 21
                color: playMouse.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    color: Theme.background
                    text: root.isPlaying ? "󰏤" : "󰐊"
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player) {
                            if (typeof root.player.togglePlaying === "function") {
                                root.player.togglePlaying();
                            } else if (root.player.isPlaying !== undefined) {
                                root.player.isPlaying = !root.player.isPlaying;
                            }
                        }
                    }
                }
            }

            // Suivant
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: nextMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: root.player ? Theme.textPrimary : Theme.textDisabled
                    text: "󰒭"
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player) root.player.next();
                    }
                }
            }
        }
    }
}
