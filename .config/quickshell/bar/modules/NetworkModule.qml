import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property var lastRx: 0
    property var lastTx: 0
    property var lastTime: 0
    property string totalSpeedFormatted: "0 o/s"

    // Popup paresseuse : voir CpuModule pour le détail du mécanisme LazyPopup.
    LazyPopup {
        id: netLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            NetworkPopup {
                parentWindow: root.parentWindow
                anchorItem: root
            }
        }
    }

    // Sélection intelligente de l'interface réseau active :
    // Priorité au Wi-Fi connecté (attente utilisateur pour ce module), puis au Filaire connecté,
    // puis au Wi-Fi présent (même déconnecté), puis au premier périphérique disponible.
    // Doc Quickshell v0.3.1 : Quickshell.Networking.DeviceType (Wifi, Wired, None).
    readonly property var activeDevice: {
        if (!Networking.devices || !Networking.devices.values) return null;
        var devs = Networking.devices.values;
        var wifiDev = null;
        var wiredDev = null;

        for (var i = 0; i < devs.length; i++) {
            var d = devs[i];
            if (!d) continue;
            var isConn = (d.connected || d.state === ConnectionState.Connected);
            if (d.type === DeviceType.Wifi) {
                if (isConn) return d;
                if (!wifiDev) wifiDev = d;
            } else if (d.type === DeviceType.Wired) {
                if (isConn && !wiredDev) wiredDev = d;
            }
        }

        if (wiredDev) return wiredDev;
        if (wifiDev) return wifiDev;
        return devs.length > 0 ? devs[0] : null;
    }

    readonly property bool isConnected: activeDevice && (activeDevice.connected || activeDevice.state === ConnectionState.Connected)
    readonly property bool isWifi: activeDevice && activeDevice.type === DeviceType.Wifi
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/DeviceType/) :
    // L'énumération est DeviceType.Wired (DeviceType.Ethernet n'existe pas dans Quickshell).
    readonly property bool isWired: activeDevice && activeDevice.type === DeviceType.Wired

    // Résolution du réseau Wi-Fi connecté via le modèle de réseaux Quickshell.
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/NetworkDevice/) :
    // Les réseaux sont exposés via l'ObjectModel `networks` (lire via `.values`).
    readonly property var connectedWifiNetwork: {
        if (!isWifi || !activeDevice || !activeDevice.networks || !activeDevice.networks.values) return null;
        var nets = activeDevice.networks.values;
        for (var i = 0; i < nets.length; i++) {
            if (nets[i] && (nets[i].connected || nets[i].state === ConnectionState.Connected)) {
                return nets[i];
            }
        }
        return null;
    }

    readonly property string netIcon: {
        if (!isConnected) return isWifi ? "󰤮" : "󰌙";
        if (isWifi) {
            // Doc Quickshell.Networking/WifiNetwork v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/WifiNetwork/) :
            // signalStrength est un réel 0.0–1.0. Conversion sur une échelle 0–100 pour les seuils d'icônes.
            var strength = connectedWifiNetwork ? connectedWifiNetwork.signalStrength : 1.0;
            var signal = Math.round(Math.max(0, Math.min(1, strength)) * 100);
            if (signal >= 80) return "󰤨";
            if (signal >= 60) return "󰤥";
            if (signal >= 40) return "󰤢";
            if (signal >= 20) return "󰤟";
            return "󰤯";
        }
        if (isWired) return "󰌘";
        return isWifi ? "󰤮" : "󰌙";
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"
        watchChanges: false
        blockAllReads: true
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
                root.totalSpeedFormatted = Theme.formatSpeed(totalBytesPerSec);
            }

            root.lastRx = totalRx;
            root.lastTx = totalTx;
            root.lastTime = now;
        }
    }

    icon: netIcon
    iconColor: isConnected ? Theme.accent : Theme.textDisabled
    text: isConnected ? totalSpeedFormatted : "Déconnecté"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    widthPercent: Theme.moduleWidthPercentNetwork

    onClicked: {
        netLazy.toggle();
    }

    onRightClicked: {
        Quickshell.execDetached(["kitty", "-e", "nmtui"]);
    }
}
