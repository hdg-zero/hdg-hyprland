import QtQuick
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property var parentWindow: null
    property var lastRx: 0
    property var lastTx: 0
    property var lastTime: 0
    property string totalSpeedFormatted: "0 o/s"

    NetworkPopup {
        id: netPopup
        parentWindow: root.parentWindow
        anchorItem: root
    }

    readonly property var activeDevice: {
        if (!Networking.devices || !Networking.devices.values) return null;
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++) {
            if (devs[i].state === ConnectionState.Connected) {
                return devs[i];
            }
        }
        return devs.length > 0 ? devs[0] : null;
    }

    readonly property bool isConnected: activeDevice && activeDevice.state === ConnectionState.Connected
    readonly property bool isWifi: activeDevice && activeDevice.type === DeviceType.Wifi
    readonly property bool isWired: activeDevice && activeDevice.type === DeviceType.Ethernet

    readonly property string netIcon: {
        if (!isConnected) return "󰌙";
        if (isWired) return "󰌘";
        if (isWifi) {
            var signal = (activeDevice && activeDevice.network) ? activeDevice.network.signalStrength : 100;
            if (signal >= 80) return "󰤨";
            if (signal >= 60) return "󰤥";
            if (signal >= 40) return "󰤢";
            if (signal >= 20) return "󰤟";
            return "󰤯";
        }
        return "󰌘";
    }

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) {
            return Math.round(bytesPerSec) + " o/s";
        } else if (bytesPerSec < 1048576) {
            return (bytesPerSec / 1024).toFixed(1) + " Ko/s";
        } else if (bytesPerSec < 1073741824) {
            return (bytesPerSec / 1048576).toFixed(1) + " Mo/s";
        } else {
            return (bytesPerSec / 1073741824).toFixed(2) + " Go/s";
        }
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"
        watchChanges: false
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            netDevFile.reload();
            var content = netDevFile.text();
            if (!content) return;

            var now = Date.now();
            var totalRx = 0;
            var totalTx = 0;

            var lines = content.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                var colonIdx = line.indexOf(":");
                if (colonIdx === -1) continue;

                var iface = line.substring(0, colonIdx).trim();
                if (iface === "lo") continue;

                var statsStr = line.substring(colonIdx + 1).trim();
                var parts = statsStr.split(/\s+/);
                if (parts.length >= 9) {
                    var rx = parseInt(parts[0]) || 0;
                    var tx = parseInt(parts[8]) || 0;
                    totalRx += rx;
                    totalTx += tx;
                }
            }

            if (root.lastTime > 0 && now > root.lastTime) {
                var deltaSec = (now - root.lastTime) / 1000.0;
                var rxDelta = Math.max(0, totalRx - root.lastRx);
                var txDelta = Math.max(0, totalTx - root.lastTx);

                var totalBytesPerSec = (rxDelta + txDelta) / deltaSec;
                root.totalSpeedFormatted = root.formatSpeed(totalBytesPerSec);
            }

            root.lastRx = totalRx;
            root.lastTx = totalTx;
            root.lastTime = now;
        }
    }

    icon: netIcon
    iconColor: isConnected ? Theme.accent : Theme.textDisabled
    text: isConnected ? totalSpeedFormatted : "Déconnecté"
    textColor: isConnected ? Theme.textPrimary : Theme.textDisabled
    customPaddingH: Theme.spacingMd
    customPaddingV: Theme.spacingSm
    customWidth: 120

    onClicked: {
        netPopup.toggle();
    }

    onRightClicked: {
        Hyprland.dispatch("hl.dsp.exec_cmd('kitty -e nmtui')");
    }
}
