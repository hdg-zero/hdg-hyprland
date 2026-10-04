import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import "../../theme"
import "../"
import "../../caffeine"

ColumnLayout {
    id: root

    property var targetScreen: null
    spacing: Theme.spacingSm

    // Suivi réactif natif PipeWire (zéro polling, synchronisation instantanée avec le système)
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // États matériels réactifs
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/Networking/) :
    // Networking.wifiEnabled est un booléen en lecture/écriture relié directement au commutateur logiciel rfkill.
    readonly property bool wifiEnabled: Networking.wifiEnabled
    property bool btEnabled: true
    readonly property bool micMuted: (source && source.audio && source.audio.muted !== undefined) ? source.audio.muted : false
    readonly property bool audioMuted: (sink && sink.audio && sink.audio.muted !== undefined) ? sink.audio.muted : false

    Process {
        id: getBtStatus
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo true || echo false"]
        stdout: StdioCollector { id: btOut }
        onExited: { root.btEnabled = (btOut.text.trim() === "true"); }
    }

    function refresh() {
        if (!getBtStatus.running) getBtStatus.running = true;
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        PanelIconButton {
            Layout.fillWidth: true
            tile: true
            glyph: root.wifiEnabled ? "󰖩" : "󰖪"
            description: "Wi-Fi"
            selected: root.wifiEnabled
            onClicked: {
                var nextState = !Networking.wifiEnabled;
                Networking.wifiEnabled = nextState;
                Quickshell.execDetached(["sh", "-c", "command -v rfkill >/dev/null 2>&1 && rfkill " + (nextState ? "unblock" : "block") + " wifi || true"]);
            }
        }

        PanelIconButton {
            Layout.fillWidth: true
            tile: true
            glyph: root.btEnabled ? "󰂯" : "󰂲"
            description: "Bluetooth"
            selected: root.btEnabled
            onClicked: {
                Quickshell.execDetached(["bluetoothctl", "power", root.btEnabled ? "off" : "on"]);
                root.btEnabled = !root.btEnabled;
                if (!getBtStatus.running) getBtStatus.running = true;
            }
        }

        PanelIconButton {
            Layout.fillWidth: true
            tile: true
            glyph: CaffeineService.active ? "󰅶" : "󰾪"
            description: "Caféine"
            selected: CaffeineService.active
            onClicked: CaffeineService.toggle()
        }

        PanelIconButton {
            Layout.fillWidth: true
            tile: true
            glyph: root.micMuted ? "󰍭" : "󰍬"
            description: root.micMuted ? "Activer le micro" : "Couper le micro"
            selected: !root.micMuted
            destructive: root.micMuted
            onClicked: {
                if (root.source && root.source.audio && root.source.audio.muted !== undefined) {
                    root.source.audio.muted = !root.source.audio.muted;
                } else {
                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                }
            }
        }

        PanelIconButton {
            Layout.fillWidth: true
            tile: true
            glyph: root.audioMuted ? "󰝟" : "󰕾"
            description: root.audioMuted ? "Activer le son" : "Couper le son"
            selected: !root.audioMuted
            destructive: root.audioMuted
            onClicked: {
                if (root.sink && root.sink.audio && root.sink.audio.muted !== undefined) {
                    root.sink.audio.muted = !root.sink.audio.muted;
                } else {
                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                }
            }
        }
    }
}
