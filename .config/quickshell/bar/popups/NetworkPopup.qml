import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property string ipAddress: "127.0.0.1"
    property string defaultGateway: "N/A"
    property string activeIface: "lo"
    property string rxRate: "0 o/s"
    property string txRate: "0 o/s"
    property string rxTotal: "0 Go"
    property string txTotal: "0 Go"

    cardWidth: 300
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

    function formatTotal(bytes) {
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " Ko";
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + " Mo";
        return (bytes / 1073741824).toFixed(2) + " Go";
    }

    Process {
        id: getNetDetails
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{print $5, $7, $3}' || echo 'lo 127.0.0.1 127.0.0.1'"]
        stdout: StdioCollector {
            id: netIpOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = netIpOut.text.trim();
            if (!str) return;
            var parts = str.split(/\s+/);
            if (parts.length >= 2) {
                root.activeIface = parts[0];
                root.ipAddress = parts[1];
                if (parts.length >= 3) root.defaultGateway = parts[2];
            }
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

                root.rxRate = root.formatSpeed(rxDelta / deltaSec);
                root.txRate = root.formatSpeed(txDelta / deltaSec);
            }

            root.rxTotal = root.formatTotal(totalRx);
            root.txTotal = root.formatTotal(totalTx);

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
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.isConnected ? Theme.accent : Theme.textDisabled
                text: root.isWifi ? "󰤨" : (root.isWired ? "󰌘" : "󰌙")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.isConnected ? (root.isWifi ? root.ssid : "Connexion Filaire") : "Déconnecté"
                    elide: Text.ElideRight
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.isConnected ? Theme.success : Theme.textDisabled
                    text: root.isConnected ? ("Interface : " + root.activeIface + (root.isWifi ? (" (" + root.signal + "%)") : "")) : "Aucune connexion"
                }
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

        // Adresses IP
        RowLayout {
            Layout.fillWidth: true
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "Adresse IPv4 :"
            }
            Item { Layout.fillWidth: true }
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.ipAddress
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "Passerelle :"
            }
            Item { Layout.fillWidth: true }
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.defaultGateway
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

        // Débits temps réel séparés
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMd

            // Download
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.success
                    text: "󰁝"
                }
                ColumnLayout {
                    spacing: 0
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textSecondary
                        text: "Téléchargement"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textPrimary
                        text: root.rxRate
                    }
                }
            }

            // Upload
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.accent
                    text: "󰁪"
                }
                ColumnLayout {
                    spacing: 0
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textSecondary
                        text: "Téléversement"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textPrimary
                        text: root.txRate
                    }
                }
            }
        }

        // Totaux session
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.textDisabled
                text: "Total : ↓ " + root.rxTotal + "  ↑ " + root.txTotal
            }
        }

        // Boutons Réseau
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingSm
            spacing: Theme.spacingSm

            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: Theme.radiusMedium
                color: nmMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: Theme.glassBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accent
                        text: "󰛳"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: "Gestionnaire"
                    }
                }

                MouseArea {
                    id: nmMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["nm-connection-editor"]);
                        root.close();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: Theme.radiusMedium
                color: nmtuiMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: Theme.glassBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accent
                        text: "󰆍"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: "nmtui"
                    }
                }

                MouseArea {
                    id: nmtuiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["kitty", "-e", "nmtui"]);
                        root.close();
                    }
                }
            }
        }
    }
}
