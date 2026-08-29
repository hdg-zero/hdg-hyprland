import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property var targetPlayer: null
    widthPercent: Theme.popupWidthPercentWide
    cardHeight: mprisCol.implicitHeight + Theme.spacingMd * 2
    readonly property var player: targetPlayer ? targetPlayer : {
        if (!Mpris.players || !Mpris.players.values) return null;
        var list = Mpris.players.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Playing) {
                return list[i];
            }
        }
        for (var j = 0; j < list.length; j++) {
            if (list[j].trackTitle && list[j].trackTitle.length > 0) {
                return list[j];
            }
        }
        return list.length > 0 ? list[0] : null;
    }
    readonly property bool isPlaying: player ? (player.playbackState === MprisPlaybackState.Playing) : false

    readonly property int coverSize: Math.round(effectiveWidth * 0.72)
    readonly property int btnSmallSize: Math.round(coverSize * 0.22)
    readonly property int btnPlaySize: Math.round(coverSize * 0.28)

    ColumnLayout {
        id: mprisCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // Pochette d'album centrée en haut (proportionnelle à la largeur de carte)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: root.coverSize
            height: root.coverSize
            radius: Theme.radiusMedium
            color: Qt.rgba(1, 1, 1, 0.05)
            clip: true
            border.color: Theme.glassBorder
            border.width: 1

            Image {
                id: albumArt
                anchors.fill: parent
                source: (root.visible && root.player) ? (root.player.trackArtUrl || root.player.artUrl || "") : ""
                sourceSize: Qt.size(root.coverSize * 2, root.coverSize * 2)
                fillMode: Image.PreserveAspectCrop
                visible: source !== "" && status === Image.Ready
                smooth: true
                cache: true
            }

            Text {
                anchors.centerIn: parent
                visible: !albumArt.visible
                font.family: Theme.fontFamily
                font.pixelSize: Math.round(root.coverSize * 0.35)
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
                font.pixelSize: Theme.fontSizeHeader
                font.bold: true
                color: Theme.textPrimary
                text: root.player ? (root.player.trackTitle || "Aucune lecture") : "Aucun lecteur"
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
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

        // Boutons de commandes multimédia proportionnels
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingLg

            // Précédent
            Rectangle {
                width: root.btnSmallSize
                height: root.btnSmallSize
                radius: width / 2
                color: prevMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHeader
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

            // Lecture / Pause (Bouton d'action principal)
            Rectangle {
                width: root.btnPlaySize
                height: root.btnPlaySize
                radius: width / 2
                color: playMouse.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle + 2
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
                width: root.btnSmallSize
                height: root.btnSmallSize
                radius: width / 2
                color: nextMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHeader
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
