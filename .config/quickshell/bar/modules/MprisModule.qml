import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components"
import "../popups"

Item {
    id: root

    property var parentWindow: null

    MprisPopup {
        id: mprisPopup
        parentWindow: root.parentWindow
        anchorItem: pill
    }

    readonly property var activePlayer: {
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
        return null;
    }

    visible: activePlayer !== null
    implicitWidth: visible ? pill.implicitWidth : 0
    implicitHeight: visible ? pill.implicitHeight : 0

    PillButton {
        id: pill
        anchors.fill: parent

        readonly property bool isPlaying: root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing
        readonly property string trackText: {
            if (!root.activePlayer) return "";
            var title = root.activePlayer.trackTitle || "";
            var rawArtists = root.activePlayer.trackArtists;
            var artist = "";
            if (rawArtists !== null && rawArtists !== undefined) {
                if (typeof rawArtists.join === "function") {
                    artist = rawArtists.join(", ");
                } else if (typeof rawArtists === "string") {
                    artist = rawArtists;
                } else if (rawArtists.length !== undefined) {
                    var parts = [];
                    for (var k = 0; k < rawArtists.length; k++) {
                        parts.push(rawArtists[k]);
                    }
                    artist = parts.join(", ");
                } else {
                    artist = rawArtists.toString();
                }
            } else if (root.activePlayer.trackArtist) {
                artist = "" + root.activePlayer.trackArtist;
            }
            if (artist.length > 0) {
                return artist + " - " + title;
            }
            return title;
        }

        icon: isPlaying ? "󰐊" : "󰏤"
        iconColor: isPlaying ? Theme.accent : Theme.textDisabled
        text: trackText
        textColor: Theme.textSecondary
        customPaddingH: Theme.spacingMd
        customPaddingV: Theme.spacingSm
        parentWindow: root.parentWindow
        widthPercent: Theme.moduleWidthPercentMpris

        onClicked: {
            if (root.activePlayer) {
                if (typeof root.activePlayer.togglePlaying === "function") {
                    root.activePlayer.togglePlaying();
                } else if (root.activePlayer.isPlaying !== undefined) {
                    root.activePlayer.isPlaying = !root.activePlayer.isPlaying;
                }
            }
        }

        onRightClicked: {
            mprisPopup.toggle();
        }

        onMiddleClicked: {
            if (root.activePlayer && root.activePlayer.canGoNext) {
                root.activePlayer.next();
            }
        }

        onScrolled: function(wheel) {
            var dy = (wheel && wheel.angleDelta && wheel.angleDelta.y !== undefined)
                ? wheel.angleDelta.y
                : ((wheel && wheel.delta !== undefined) ? wheel.delta : 0);

            if (dy > 0) {
                if (root.activePlayer && root.activePlayer.canGoNext) {
                    root.activePlayer.next();
                }
            } else if (dy < 0) {
                if (root.activePlayer && root.activePlayer.canGoPrevious) {
                    root.activePlayer.previous();
                }
            }
        }
    }
}
