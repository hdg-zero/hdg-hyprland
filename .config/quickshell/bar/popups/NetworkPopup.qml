import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Io
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property string ipAddress: "127.0.0.1"
    property string rxRate: "0 o/s"
    property string txRate: "0 o/s"

    widthPercent: Theme.popupWidthPercentStandard
    cardHeight: netCol.implicitHeight + Theme.spacingMd * 2

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
    readonly property string ssid: (isWifi && activeDevice.network) ? activeDevice.network.ssid : "Filaire"
    readonly property int signal: (isWifi && activeDevice.network) ? activeDevice.network.signalStrength : 100

    property var lastRx: 0
    property var lastTx: 0
    property var lastTime: 0

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) return Math.round(bytesPerSec) + " o/s";
        if (bytesPerSec < 1048576) return (bytesPerSec / 1024).toFixed(1) + " Ko/s";
        if (bytesPerSec < 1073741824) return (bytesPerSec / 1048576).toFixed(1) + " Mo/s";
        return (bytesPerSec / 1073741824).toFixed(2) + " Go/s";
    }

    Process {
        id: getNetDetails
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || echo '127.0.0.1'"]
        stdout: StdioCollector {
            id: netIpOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = netIpOut.text.trim();
            if (str) root.ipAddress = str;
        }
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"
        watchChanges: false
    }

    Timer {
        interval: 1500
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getNetDetails.running) {
                getNetDetails.running = true;
            }

            netDevFile.reload();
            var content = typeof netDevFile.text === "function" ? netDevFile.text() : (netDevFile.text || "");
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

                root.rxRate = root.formatSpeed(rxDelta / deltaSec);
                root.txRate = root.formatSpeed(txDelta / deltaSec);
            }

            root.lastRx = totalRx;
            root.lastTx = totalTx;
            root.lastTime = now;
        }
    }

    onVisibleChanged: {
        if (visible) {
            getNetDetails.running = true;
        }
    }

    ColumnLayout {
        id: netCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: root.isConnected ? Theme.accent : Theme.textDisabled
                text: root.isWifi ? "󰤨" : (root.isWired ? "󰌘" : "󰌙")
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.isConnected ? (root.isWifi ? root.ssid : "Filaire") : "Déconnecté"
                elide: Text.ElideRight
            }

            Text {
                visible: root.isWifi && root.isConnected
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: root.signal + "%"
            }
        }

        // Séparateur fin
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // IP & Débits
        RowLayout {
            Layout.fillWidth: true

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "IP " + root.ipAddress
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.accent
                text: "↓" + root.rxRate + "  ↑" + root.txRate
            }
        }
    }
}
