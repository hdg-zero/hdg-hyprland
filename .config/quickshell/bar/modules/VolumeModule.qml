import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Io
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property int wpVolumePercent: 0
    property bool wpMuted: false
    property bool wpIsBluetooth: false
    property bool hasWpSync: false

    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.preferredDefaultAudioSink
        ]
    }

    readonly property var sink: Pipewire.defaultAudioSink ?? Pipewire.preferredDefaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    
    readonly property bool isBluetooth: {
        if (sink) {
            var name = (sink.name || "").toLowerCase();
            var desc = (sink.description || "").toLowerCase();
            var nick = (sink.nickname || "").toLowerCase();
            if (name.indexOf("bluez") !== -1 || desc.indexOf("bluetooth") !== -1 || nick.indexOf("bluez") !== -1) {
                return true;
            }
            if (sink.properties) {
                var bus = (sink.properties["device.bus"] || "").toLowerCase();
                var api = (sink.properties["device.api"] || "").toLowerCase();
                if (bus === "bluetooth" || api === "bluez5") return true;
            }
        }
        return wpIsBluetooth;
    }

    readonly property bool isMuted: (audio && audio.muted !== undefined) ? audio.muted : wpMuted
    readonly property real volumeLevel: (audio && audio.volume !== undefined) ? audio.volume : (wpVolumePercent / 100.0)
    readonly property int volumePercent: (audio && audio.volume !== undefined) ? Math.round(audio.volume * 100) : wpVolumePercent

    // Popup paresseuse : voir CpuModule pour le détail du mécanisme LazyPopup.
    LazyPopup {
        id: volLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            VolumePopup {
                volumePercent: root.volumePercent
                isMuted: root.isMuted
                isBluetooth: root.isBluetooth
            }
        }
    }

    Process {
        id: getWpVolume
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@; wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -iE 'bluez|device.bus.*bluetooth' || true"]
        stdout: StdioCollector {
            id: wpOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = wpOut.text.trim();
            if (!str) return;
            var lines = str.split("\n");
            var volLine = lines[0] || "";
            var parts = volLine.split(/\s+/);
            if (parts.length >= 2) {
                var vol = parseFloat(parts[1]) || 0;
                root.wpVolumePercent = Math.round(vol * 100);
                root.wpMuted = volLine.indexOf("[MUTED]") !== -1;
                root.hasWpSync = true;
            }
            root.wpIsBluetooth = lines.length > 1 && lines.slice(1).join(" ").length > 0;
        }
    }

    Timer {
        interval: 5000
        running: root.audio === null
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getWpVolume.running) {
                getWpVolume.running = true;
            }
        }
    }

    icon: {
        if (isMuted) return isBluetooth ? "󰂲" : "󰝟";
        if (isBluetooth) return "󰂯";
        if (volumePercent >= 60) return "󰕾";
        if (volumePercent >= 20) return "󰖀";
        return "󰕿";
    }

    iconColor: isMuted ? Theme.destructive : (volumePercent > 100 ? Theme.warning : Theme.accent)
    text: isMuted ? "Muet" : volumePercent + "%"
    textColor: isMuted ? Theme.textDisabled : Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        volLazy.toggle();
    }

    onRightClicked: {
        Quickshell.execDetached(["pavucontrol", "-t", "3"]);
    }

    onScrolled: function(wheel) {
        var dy = (wheel && wheel.angleDelta && wheel.angleDelta.y !== undefined)
            ? wheel.angleDelta.y
            : ((wheel && wheel.delta !== undefined) ? wheel.delta : 0);

        if (dy > 0) {
            Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+"]);
        } else if (dy < 0) {
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]);
        }
        syncTimer.restart();
    }

    Timer {
        id: syncTimer
        interval: 80
        onTriggered: {
            if (!getWpVolume.running) {
                getWpVolume.running = true;
            }
        }
    }
}
