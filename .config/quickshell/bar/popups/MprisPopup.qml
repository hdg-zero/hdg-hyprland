import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    cardWidth: Theme.relWidth(0.16, parentWindow ? parentWindow.screen : null)
    cardHeight: mprisCol.implicitHeight + Theme.spacingMd * 2

    readonly property var player: (Mpris.players && Mpris.players.values && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null
    readonly property bool isPlaying: player ? (player.playbackState === MprisPlaybackState.Playing) : false

    ColumnLayout {
        id: mprisCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // Pochette d'album centrée en haut
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 140
            height: 140
            radius: Theme.radiusMedium
            color: Qt.rgba(1, 1, 1, 0.05)
            clip: true
            border.color: Theme.glassBorder
            border.width: 1

            Image {
                id: albumArt
                anchors.fill: parent
                source: (root.visible && root.player) ? (root.player.trackArtUrl || root.player.artUrl || "") : ""
                sourceSize: Qt.size(280, 280)
                fillMode: Image.PreserveAspectCrop
                visible: source !== "" && status === Image.Ready
                smooth: true
                asynchronous: true
                cache: true
            }

            Text {
                anchors.centerIn: parent
                visible: !albumArt.visible
                font.family: Theme.fontFamily
                font.pixelSize: 42
                color: Theme.textDisabled
                text: "󰝚"
            }
        }

        // Métadonnées centrées : Titre, Artiste, Album
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: root.player ? (root.player.trackTitle || "Aucune lecture") : "Aucun lecteur"
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeRegular
                color: Theme.accent
                text: root.player ? (root.player.trackArtist || "Artiste inconnu") : ""
                elide: Text.ElideRight
                visible: text !== ""
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: root.player ? (root.player.trackAlbum || (root.player.identity || "")) : ""
                elide: Text.ElideRight
                visible: text !== ""
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

        // Boutons de commandes centrés en bas
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingLg

            // Précédent
            Rectangle {
                width: 36
                height: 36
                radius: width / 2
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
                width: 46
                height: 46
                radius: width / 2
                color: playMouse.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
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
                width: 36
                height: 36
                radius: width / 2
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
