import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications as Notifs
import "../theme"
import "../components"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + Theme.spacingSm)
        bottom: Theme.spacingLg
        right: Theme.spacingLg
    }

    implicitWidth: Math.max(400, Math.round(Theme.relWidth(0.22, root.screen)))

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    visible: NotificationService.panelVisible

    // États matériels
    property bool wifiEnabled: true
    property string wifiSsid: ""
    property bool btEnabled: true
    property bool micMuted: false
    property bool audioMuted: false
    property int currentVolume: 50
    property int currentBrightness: 100

    Process {
        id: getWifiStatus
        command: ["sh", "-c", "if nmcli radio wifi 2>/dev/null | grep -q 'enabled'; then echo 'true|'$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^oui\|^yes' | cut -d: -f2 || echo 'Connecté'); else echo 'false|Désactivé'; fi"]
        stdout: StdioCollector { id: wifiOut }
        onExited: {
            var parts = wifiOut.text.trim().split("|");
            root.wifiEnabled = (parts[0] === "true");
            root.wifiSsid = parts.length > 1 && parts[1] !== "" ? parts[1] : (root.wifiEnabled ? "Activé" : "Désactivé");
        }
    }

    Process {
        id: getBtStatus
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo true || echo false"]
        stdout: StdioCollector { id: btOut }
        onExited: { root.btEnabled = (btOut.text.trim() === "true"); }
    }

    Process {
        id: getMicStatus
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo true || echo false"]
        stdout: StdioCollector { id: micOut }
        onExited: { root.micMuted = (micOut.text.trim() === "true"); }
    }

    Process {
        id: getAudioStatus
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo true || echo false"]
        stdout: StdioCollector { id: audioOut }
        onExited: { root.audioMuted = (audioOut.text.trim() === "true"); }
    }

    Process {
        id: getVolumeVal
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}'"]
        stdout: StdioCollector { id: volOut }
        onExited: {
            var v = parseInt(volOut.text.trim());
            if (!isNaN(v)) root.currentVolume = v;
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

    function refreshStatus() {
        if (!getWifiStatus.running) getWifiStatus.running = true;
        if (!getBtStatus.running) getBtStatus.running = true;
        if (!getMicStatus.running) getMicStatus.running = true;
        if (!getAudioStatus.running) getAudioStatus.running = true;
        if (!getVolumeVal.running) getVolumeVal.running = true;
        if (!getBrightVal.running) getBrightVal.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            refreshStatus();
        }
    }

    Timer {
        interval: 3000
        running: root.visible
        repeat: true
        onTriggered: {
            root.refreshStatus();
        }
    }

    // Carte principale en Verre Obsidian
    Rectangle {
        id: panelCard
        anchors.fill: parent
        radius: Theme.radiusXLarge
        color: Qt.rgba(0.043, 0.059, 0.078, 0.95)
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            // ==========================================
            // 1. EN-TÊTE : Titre, DND, Effacer tout, Fermer
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusMedium
                    color: Qt.rgba(0.365, 0.678, 0.886, 0.15)
                    border.color: Theme.glassBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.accent
                        text: "󰂚"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                        color: Theme.textPrimary
                        text: "Centre de Contrôle"
                    }

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.textSecondary
                        text: NotificationService.unreadCount > 0 ? (NotificationService.unreadCount + " notification" + (NotificationService.unreadCount > 1 ? "s" : "")) : "À jour"
                    }
                }

                // Bouton Ne Pas Déranger (DND)
                Rectangle {
                    implicitWidth: dndRow.implicitWidth + Theme.spacingSm * 2
                    height: 30
                    radius: Theme.radiusPill
                    color: NotificationService.dnd ? Qt.rgba(1.0, 0.72, 0.42, 0.25) : (dndMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05))
                    border.color: NotificationService.dnd ? Theme.warning : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        id: dndRow
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: NotificationService.dnd ? Theme.warning : Theme.textSecondary
                            text: NotificationService.dnd ? "󰂛" : "󰂚"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: NotificationService.dnd ? Theme.warning : Theme.textSecondary
                            text: "DND"
                        }
                    }

                    MouseArea {
                        id: dndMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.toggleDnd(); }
                    }
                }

                // Bouton Effacer tout
                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    implicitWidth: clearRow.implicitWidth + Theme.spacingSm * 2
                    height: 30
                    radius: Theme.radiusPill
                    color: clearMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.2) : Qt.rgba(1, 1, 1, 0.05)
                    border.color: clearMouse.containsMouse ? Theme.destructive : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        id: clearRow
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: clearMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                            text: "󰃢"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: clearMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                            text: "Effacer"
                        }
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.clearAll(); }
                    }
                }

                // Bouton Fermer le panneau
                Rectangle {
                    width: 30
                    height: 30
                    radius: width / 2
                    color: closePanelMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Theme.glassBorderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: closePanelMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                        text: "󰅖"
                    }

                    MouseArea {
                        id: closePanelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.panelVisible = false; }
                    }
                }
            }

            // ==========================================
            // 2. TOGGLES RAPIDES (Cartes Style Control Center)
            // ==========================================
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.spacingSm
                columnSpacing: Theme.spacingSm

                // Toggle 1 : Wi-Fi
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.radiusMedium
                    color: root.wifiEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.22) : Qt.rgba(1, 1, 1, 0.04)
                    border.color: root.wifiEnabled ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 34
                            height: 34
                            radius: width / 2
                            color: root.wifiEnabled ? Theme.accent : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                color: root.wifiEnabled ? Theme.backgroundSolid : Theme.textDisabled
                                text: root.wifiEnabled ? "󰖩" : "󰖪"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: "Wi-Fi"
                            }
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMicro
                                color: root.wifiEnabled ? Theme.accent : Theme.textDisabled
                                text: root.wifiSsid
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "nmcli radio wifi " + (root.wifiEnabled ? "off" : "on")]);
                            root.wifiEnabled = !root.wifiEnabled;
                            getWifiStatus.running = true;
                        }
                    }
                }

                // Toggle 2 : Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.radiusMedium
                    color: root.btEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.22) : Qt.rgba(1, 1, 1, 0.04)
                    border.color: root.btEnabled ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 34
                            height: 34
                            radius: width / 2
                            color: root.btEnabled ? Theme.accent : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                color: root.btEnabled ? Theme.backgroundSolid : Theme.textDisabled
                                text: root.btEnabled ? "󰂯" : "󰂲"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: "Bluetooth"
                            }
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMicro
                                color: root.btEnabled ? Theme.accent : Theme.textDisabled
                                text: root.btEnabled ? "Activé" : "Désactivé"
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "bluetoothctl power " + (root.btEnabled ? "off" : "on")]);
                            root.btEnabled = !root.btEnabled;
                            getBtStatus.running = true;
                        }
                    }
                }

                // Toggle 3 : Micro
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.radiusMedium
                    color: !root.micMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.22) : Qt.rgba(1.0, 0.42, 0.42, 0.15)
                    border.color: !root.micMuted ? Theme.accent : Qt.rgba(1.0, 0.42, 0.42, 0.4)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 34
                            height: 34
                            radius: width / 2
                            color: !root.micMuted ? Theme.accent : Theme.destructive

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.backgroundSolid
                                text: !root.micMuted ? "󰍬" : "󰍭"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: "Microphone"
                            }
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMicro
                                color: !root.micMuted ? Theme.accent : Theme.destructive
                                text: !root.micMuted ? "Actif" : "Muet"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                            root.micMuted = !root.micMuted;
                            getMicStatus.running = true;
                        }
                    }
                }

                // Toggle 4 : Mute Audio
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: Theme.radiusMedium
                    color: !root.audioMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.22) : Qt.rgba(1.0, 0.42, 0.42, 0.15)
                    border.color: !root.audioMuted ? Theme.accent : Qt.rgba(1.0, 0.42, 0.42, 0.4)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 34
                            height: 34
                            radius: width / 2
                            color: !root.audioMuted ? Theme.accent : Theme.destructive

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.backgroundSolid
                                text: !root.audioMuted ? "󰕾" : "󰝟"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: "Audio"
                            }
                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMicro
                                color: !root.audioMuted ? Theme.accent : Theme.destructive
                                text: !root.audioMuted ? "Actif" : "Muet"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                            root.audioMuted = !root.audioMuted;
                            getAudioStatus.running = true;
                        }
                    }
                }
            }

            // ==========================================
            // 3. CURSEURS RAPIDES (Volume & Luminosité)
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: slidersCol.implicitHeight + Theme.spacingMd * 2
                radius: Theme.radiusLarge
                color: Qt.rgba(1, 1, 1, 0.03)
                border.color: Theme.glassBorderSubtle
                border.width: 1

                ColumnLayout {
                    id: slidersCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacingMd
                    }
                    spacing: Theme.spacingMd

                    // Slider Volume
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 30
                            height: 30
                            radius: width / 2
                            color: root.audioMuted ? Qt.rgba(1.0, 0.42, 0.42, 0.2) : Qt.rgba(0.365, 0.678, 0.886, 0.15)

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: root.audioMuted ? Theme.destructive : Theme.accent
                                text: root.audioMuted ? "󰝟" : (root.currentVolume > 50 ? "󰕾" : "󰖀")
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                                    root.audioMuted = !root.audioMuted;
                                }
                            }
                        }

                        Rectangle {
                            id: volSliderTrack
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1.0, root.currentVolume / 100.0)
                                radius: 5
                                color: root.audioMuted ? Theme.destructive : Theme.accent

                                Behavior on width { NumberAnimation { duration: 80 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                function setVol(mouseX) {
                                    var pct = Math.max(0, Math.min(100, Math.round((mouseX / width) * 100)));
                                    root.currentVolume = pct;
                                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
                                }
                                onPressed: function(mouse) { setVol(mouse.x); }
                                onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
                            }
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.textPrimary
                            text: root.currentVolume + "%"
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // Slider Luminosité
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 30
                            height: 30
                            radius: width / 2
                            color: Qt.rgba(0.365, 0.678, 0.886, 0.15)

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.accent
                                text: "󰃠"
                            }
                        }

                        Rectangle {
                            id: brightSliderTrack
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Rectangle {
                                height: parent.height
                                width: parent.width * Math.min(1.0, root.currentBrightness / 100.0)
                                radius: 5
                                color: Theme.accent

                                Behavior on width { NumberAnimation { duration: 80 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                function setBright(mouseX) {
                                    var pct = Math.max(5, Math.min(100, Math.round((mouseX / width) * 100)));
                                    root.currentBrightness = pct;
                                    Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
                                }
                                onPressed: function(mouse) { setBright(mouse.x); }
                                onPositionChanged: function(mouse) { if (pressed) setBright(mouse.x); }
                            }
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.textPrimary
                            text: root.currentBrightness + "%"
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // ==========================================
            // 4. BOUTONS D'ACTIONS SYSTÈME (Lock & Session)
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // Verrouiller
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusMedium
                    color: lockMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.04)
                    border.color: Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.accent
                            text: "󰌾"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Verrouiller"
                        }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["hyprlock"]); }
                    }
                }

                // Éteindre / Menu Wlogout
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusMedium
                    color: pwrMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                    border.color: pwrMouse.containsMouse ? Theme.destructive : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.destructive
                            text: "⏻"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Session"
                        }
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["wlogout"]); }
                    }
                }
            }

            // Séparateur fin
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.glassBorder
            }

            // ==========================================
            // 5. HISTORIQUE DES NOTIFICATIONS
            // ==========================================
            RowLayout {
                Layout.fillWidth: true

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Notifications"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    width: 22
                    height: 22
                    radius: width / 2
                    color: Theme.accent

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold: true
                        color: Theme.backgroundSolid
                        text: NotificationService.unreadCount.toString()
                    }
                }
            }

            // Liste défilante des notifications
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // État vide élégant
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: NotificationService.unreadCount === 0
                    spacing: Theme.spacingSm

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 54
                        height: 54
                        radius: width / 2
                        color: Qt.rgba(1, 1, 1, 0.03)
                        border.color: Theme.glassBorderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTitle
                            color: Theme.textDisabled
                            text: "󰂚"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textSecondary
                        text: "Aucune notification"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.textDisabled
                        text: "Vous êtes à jour"
                    }
                }

                // Vue Liste
                ListView {
                    id: notifList
                    anchors.fill: parent
                    visible: NotificationService.unreadCount > 0
                    model: (NotificationService.trackedNotifications && NotificationService.trackedNotifications.values) ? NotificationService.trackedNotifications.values : []
                    clip: true
                    spacing: Theme.spacingSm

                    delegate: Rectangle {
                        id: notifCard
                        required property var modelData
                        width: notifList.width
                        implicitHeight: cardInnerCol.implicitHeight + Theme.spacingMd * 2
                        radius: Theme.radiusLarge
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: cardHover.containsMouse ? Theme.glassBorder : Theme.glassBorderSubtle
                        border.width: 1

                        Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                        MouseArea {
                            id: cardHover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }

                        ColumnLayout {
                            id: cardInnerCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: Theme.spacingMd
                            }
                            spacing: Theme.spacingXs

                            // En-tête de la notification
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingSm

                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: Theme.radiusSmall
                                    color: Qt.rgba(0.365, 0.678, 0.886, 0.2)

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeTiny
                                        color: Theme.accent
                                        text: "󰂚"
                                    }
                                }

                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.accent
                                    text: modelData.appName || "Application"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: width / 2
                                    color: itemDelMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.2) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeTiny
                                        color: itemDelMouse.containsMouse ? Theme.destructive : Theme.textDisabled
                                        text: "󰅖"
                                    }

                                    MouseArea {
                                        id: itemDelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            NotificationService.dismissNotification(modelData);
                                        }
                                    }
                                }
                            }

                            // Titre
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: modelData.summary || ""
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Corps
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                                text: modelData.body || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Boutons d'actions
                            RowLayout {
                                Layout.fillWidth: true
                                visible: modelData.actions && modelData.actions.values && modelData.actions.values.length > 0
                                spacing: Theme.spacingXs
                                Layout.topMargin: Theme.spacingXs

                                Repeater {
                                    model: modelData.actions ? modelData.actions.values : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitWidth: actLabel.implicitWidth + Theme.spacingSm * 2
                                        implicitHeight: 24
                                        radius: Theme.radiusSmall
                                        color: actBtnMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.08)
                                        border.color: Theme.glassBorderSubtle
                                        border.width: 1

                                        Text {
                                            id: actLabel
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeTiny
                                            font.bold: true
                                            color: actBtnMouse.containsMouse ? Theme.backgroundSolid : Theme.textPrimary
                                            text: modelData.text || "Action"
                                        }

                                        MouseArea {
                                            id: actBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData && typeof modelData.invoke === "function") {
                                                    modelData.invoke();
                                                }
                                                NotificationService.dismissNotification(notifCard.modelData);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
