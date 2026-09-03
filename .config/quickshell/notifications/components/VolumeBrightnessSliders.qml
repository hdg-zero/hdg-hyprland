import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../theme"

ColumnLayout {
    id: root

    property var targetScreen: null
    spacing: Theme.spacingSm

    // Suivi réactif natif PipeWire pour le volume
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    // Volume synchronisé en temps réel avec PipeWire
    readonly property int currentVolume: (audio && audio.volume !== undefined)
        ? Math.round(audio.volume * 100)
        : fallbackVolume
    property int fallbackVolume: 50

    property int currentBrightness: 100
    property bool audioMuted: false

    // Debounce pour l'ajustement de luminosité (évite d'inonder le système de forks brightnessctl pendant le drag)
    Timer {
        id: brightDebounce
        interval: 40
        repeat: false
        property int pendingPct: 100
        onTriggered: {
            Quickshell.execDetached(["brightnessctl", "set", pendingPct + "%"]);
        }
    }

    Process {
        id: getBrightVal
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%'"]
        stdout: StdioCollector { id: brightOut }
        onExited: {
            var b = parseInt(brightOut.text.trim());
            if (!isNaN(b)) root.currentBrightness = b;
        }
    }

    function refresh() {
        if (!getBrightVal.running) getBrightVal.running = true;
    }

    // Capsule Slider 1 : Volume
    Rectangle {
        id: volCapsule
        Layout.fillWidth: true
        height: 42
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
        border.width: 1
        clip: true

        // Remplissage progressif
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(1.0, root.currentVolume / 100.0)
            radius: parent.radius
            color: root.audioMuted ? Qt.rgba(1.0, 0.42, 0.42, 0.8) : Qt.rgba(0.365, 0.678, 0.886, 0.85)

            Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
        }

        // Éléments superposés (icône + pourcentage)
        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spacingMd
                rightMargin: Theme.spacingMd
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.currentVolume > 15 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.audioMuted ? "󰝟" : (root.currentVolume > 50 ? "󰕾" : "󰖀")
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: root.currentVolume > 85 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.currentVolume + "%"
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            function setVol(mouseX) {
                var pct = Math.max(0, Math.min(100, Math.round((mouseX / width) * 100)));
                if (root.audio && root.audio.volume !== undefined) {
                    root.audio.volume = pct / 100.0;
                } else {
                    root.fallbackVolume = pct;
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
                }
            }
            onPressed: function(mouse) { setVol(mouse.x); }
            onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
        }
    }

    // Capsule Slider 2 : Luminosité
    Rectangle {
        id: brightCapsule
        Layout.fillWidth: true
        height: 42
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
        border.width: 1
        clip: true

        // Remplissage progressif
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(1.0, root.currentBrightness / 100.0)
            radius: parent.radius
            color: Qt.rgba(0.365, 0.678, 0.886, 0.85)

            Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
        }

        // Éléments superposés (icône + pourcentage)
        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spacingMd
                rightMargin: Theme.spacingMd
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.currentBrightness > 15 ? Theme.backgroundSolid : Theme.textPrimary
                text: "󰃠"
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: root.currentBrightness > 85 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.currentBrightness + "%"
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            function setBright(mouseX) {
                var pct = Math.max(5, Math.min(100, Math.round((mouseX / width) * 100)));
                root.currentBrightness = pct;
                brightDebounce.pendingPct = pct;
                brightDebounce.restart();
            }
            onPressed: function(mouse) { setBright(mouse.x); }
            onPositionChanged: function(mouse) { if (pressed) setBright(mouse.x); }
        }
    }
}
