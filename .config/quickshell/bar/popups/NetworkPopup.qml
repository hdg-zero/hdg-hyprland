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

    property var lastRx: 0
    property var lastTx: 0
    property var lastTime: 0

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
        blockAllReads: true
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

                root.rxRate = Theme.formatSpeed(rxDelta / deltaSec);
                root.txRate = Theme.formatSpeed(txDelta / deltaSec);
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
                text: root.isWifi ? (root.isConnected ? "󰤨" : "󰤮") : (root.isWired ? (root.isConnected ? "󰌘" : "󰌙") : "󰌙")
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.isConnected ? (root.isWifi ? root.ssid : (root.isWired ? "Filaire" : "Connecté")) : (root.isWifi ? "Non connecté" : "Déconnecté")
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

        // Séparateur fin
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Actions rapides (Connexions, nmtui, VPN)
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Bouton Gestionnaire (nm-connection-editor)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: nmMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: nmMouse.containsMouse ? Theme.accent : Theme.glassBorder
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

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
                        text: "Connexions"
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

            // Bouton nmtui (Terminal)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: nmtuiMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: nmtuiMouse.containsMouse ? Theme.accent : Theme.glassBorder
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

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

            // Bouton VPN (Mullvad)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: vpnMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                border.color: vpnMouse.containsMouse ? Theme.accent : Theme.glassBorder
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accent
                        text: "󰒄"
                    }

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: "VPN"
                    }
                }

                MouseArea {
                    id: vpnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["sh", "-c", "command -v mullvad-gui >/dev/null 2>&1 && mullvad-gui || mullvad status"]);
                        root.close();
                    }
                }
            }
        }
    }
}
