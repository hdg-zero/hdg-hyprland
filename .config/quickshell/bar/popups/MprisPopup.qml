import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property var targetPlayer: null
    cardWidth: 300
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2
    readonly property var player: {
        if (targetPlayer) return targetPlayer;
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

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Theme.spacingSm
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd
            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 12
                color: PopupStyle.activeSurface
                clip: true
                Image { id: cover; anchors.fill: parent; asynchronous: true; sourceSize.width: 64; sourceSize.height: 64; source: root.player ? root.player.trackArtUrl || "" : ""; fillMode: Image.PreserveAspectCrop }
                PopupGlyph { anchors.centerIn: parent; visible: cover.status !== Image.Ready; text: "󰝚"; font.pixelSize: 25 }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXs
                PopupText { Layout.fillWidth: true; text: root.player ? root.player.trackTitle || "Aucune lecture" : "Aucun lecteur"; font.pixelSize: 14; font.weight: Font.DemiBold }
                PopupText { Layout.fillWidth: true; visible: root.player !== null; text: root.player ? root.player.trackArtist || "" : ""; font.pixelSize: 11; color: Theme.textSecondary }
                PopupText { Layout.fillWidth: true; visible: root.player !== null; text: root.player ? root.player.trackAlbum || root.player.identity || "" : ""; font.pixelSize: 11; color: Theme.textSecondary }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            PopupIconButton { glyph: "󰒮"; description: "Précédent"; enabled: root.player && root.player.canGoPrevious; onClicked: root.player.previous() }
            PopupIconButton { implicitWidth: 38; implicitHeight: 38; glyph: root.isPlaying ? "󰏤" : "󰐊"; description: root.isPlaying ? "Mettre en pause" : "Lire"; selected: true; enabled: root.player && root.player.canTogglePlaying; onClicked: root.player.togglePlaying() }
            PopupIconButton { glyph: "󰒭"; description: "Suivant"; enabled: root.player && root.player.canGoNext; onClicked: root.player.next() }
        }
    }
}
