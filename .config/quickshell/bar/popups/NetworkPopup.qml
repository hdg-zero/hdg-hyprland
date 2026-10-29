import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Io
import "../../theme"
import "../../components"

MetricPopup {
    id: root

    property string ipAddress: ""
    property string rxRate: "—"
    property string txRate: "—"

    contentHeight: Math.max(implicitHeight, contentColumn.implicitHeight + root.contentPadding * 2)

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

    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/Network/) :
    // Le nom du réseau Wi-Fi (SSID) est la propriété `name` sur l'objet Network.
    readonly property string ssid: (isWifi && connectedWifiNetwork && connectedWifiNetwork.name)
        ? connectedWifiNetwork.name
        : (isWired ? "Filaire" : "Wi-Fi")

    // Doc Quickshell.Networking/WifiNetwork v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/WifiNetwork/) :
    // signalStrength est un réel 0.0–1.0. Conversion sur une échelle 0–100 pour l'affichage en pourcentage.
    readonly property int signal: (isWifi && connectedWifiNetwork)
        ? Math.round(Math.max(0, Math.min(1, connectedWifiNetwork.signalStrength)) * 100)
        : 100

    readonly property string interfaceName: activeDevice ? activeDevice.name : ""

    property var lastRx: 0
    property var lastTx: 0
    property var lastTime: 0

    Process {
        id: getNetDetails
        property string queryInterface: ""
        command: ["sh", "-c", "ip -o addr show dev \"$1\" scope global 2>/dev/null | awk '{split($4,a,\"/\");print a[1];exit}'", "--", getNetDetails.queryInterface]
        stdout: StdioCollector {
            id: netIpOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = netIpOut.text.trim();
            if (queryInterface === root.interfaceName && root.isConnected) root.ipAddress = str;
            else if (root.isOpen) Qt.callLater(root.refreshIp);
        }
    }

    function refreshIp() {
        if (!isOpen || !isConnected || !interfaceName || getNetDetails.running) return;
        getNetDetails.queryInterface = interfaceName;
        getNetDetails.running = true;
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"
        watchChanges: false
        preload: true
        onLoaded: root.consumeNetworkStats()
    }

    // Rafraîchissement périodique de l'adresse IP espacé à 15s (l'adresse locale ne varie pas en continu)
    function consumeNetworkStats() {
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
            if (iface !== root.interfaceName) continue;

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

            root.rxRate = Theme.formatSpeed(rxDelta / deltaSec);
            root.txRate = Theme.formatSpeed(txDelta / deltaSec);
        }

        root.lastRx = totalRx;
        root.lastTx = totalTx;
        root.lastTime = now;
    }

    Timer {
        interval: 15000
        running: root.isOpen && root.isConnected
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshIp()
    }

    Timer {
        interval: 1500
        running: root.isOpen && root.isConnected
        repeat: true
        triggeredOnStart: true
        onTriggered: netDevFile.reload()
    }

    onIsConnectedChanged: {
        lastTime = 0;
        rxRate = "—";
        txRate = "—";
        ipAddress = "";
        root.refreshIp();
    }
    onInterfaceNameChanged: {
        lastTime = 0;
        lastRx = 0;
        lastTx = 0;
        rxRate = "—";
        txRate = "—";
        ipAddress = "";
        root.refreshIp();
    }

    ColumnLayout {
        id: contentColumn
        height: Math.max(implicitHeight, root.implicitHeight - root.contentPadding * 2)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            PopupGlyph { text: root.isWifi ? "󰖩" : "󰌘"; color: root.isConnected ? PopupStyle.accentText : Theme.textDisabled }
            PopupText { Layout.fillWidth: true; text: root.isConnected ? root.ssid : "Déconnecté"; font.pixelSize: 12; color: Theme.textSecondary }
            PopupText { visible: root.isConnected && root.isWifi; text: root.signal + " %"; font.pixelSize: 11; color: Theme.textSecondary }
        }
        RowLayout {
            Layout.fillWidth: true
            visible: root.isConnected
            spacing: Theme.spacingLg
            PopupText { Layout.fillWidth: true; text: "↓ " + root.rxRate; font.pixelSize: 16; Accessible.name: "Réception : " + root.rxRate }
            PopupText { Layout.fillWidth: true; text: "↑ " + root.txRate; font.pixelSize: 16; Accessible.name: "Envoi : " + root.txRate }
        }
        Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            PopupText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: root.isConnected
                text: root.ipAddress || "Indisponible"
                font.pixelSize: 11
                color: Theme.textSecondary
                Accessible.name: "Adresse locale : " + text
            }
            PopupIconButton { Layout.alignment: Qt.AlignTop; implicitWidth: 28; implicitHeight: 28; glyph: "󰛳"; description: "Connexions"; onClicked: { Quickshell.execDetached(["nm-connection-editor"]); root.close(); } }
            PopupIconButton { Layout.alignment: Qt.AlignTop; implicitWidth: 28; implicitHeight: 28; glyph: "󰆍"; description: "nmtui"; onClicked: { Quickshell.execDetached(["kitty", "-e", "nmtui"]); root.close(); } }
            PopupIconButton { Layout.alignment: Qt.AlignTop; implicitWidth: 28; implicitHeight: 28; glyph: "󰒄"; description: "VPN"; onClicked: { Quickshell.execDetached(["sh", "-c", "command -v mullvad-gui >/dev/null 2>&1 && mullvad-gui || mullvad status"]); root.close(); } }
        }
    }
}
