import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    widthPercent: Theme.popupWidthPercentWide
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

        // Pochette et Titre
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Pochette d'album
            Rectangle {
                width: Theme.spacingXl * 2
                height: Theme.spacingXl * 2
                radius: Theme.radiusSmall
                color: Qt.rgba(1, 1, 1, 0.05)
                clip: true
                border.color: Theme.glassBorder
                border.width: 1

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: (root.visible && root.player) ? (root.player.trackArtUrl || root.player.artUrl || "") : ""
                    sourceSize: Qt.size(Theme.spacingXl * 4, Theme.spacingXl * 4)
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
                    font.pixelSize: Theme.fontSizeTitle
                    color: Theme.textDisabled
                    text: "󰝚"
                }
            }

            // Titre & Artiste
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
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
                    text: root.player ? (root.player.trackArtist || "") : ""
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }
        }

        // Contrôles multimédia compacts
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingSm

            // Précédent
            Rectangle {
                width: Theme.spacingLg * 1.8
                height: Theme.spacingLg * 1.8
                radius: width / 2
                color: prevMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
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

            // Lecture / Pause
            Rectangle {
                width: Theme.spacingLg * 2
                height: Theme.spacingLg * 2
                radius: width / 2
                color: playMouse.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
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
                width: Theme.spacingLg * 1.8
                height: Theme.spacingLg * 1.8
                radius: width / 2
                color: nextMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
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
