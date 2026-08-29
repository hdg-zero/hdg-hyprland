import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../session"

ColumnLayout {
    id: root

    property var targetScreen: null
    spacing: Theme.spacingSm

    // États matériels
    property bool wifiEnabled: true
    property bool btEnabled: true
    property bool micMuted: false
    property bool audioMuted: false

    Process {
        id: getWifiStatus
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null | grep -q 'enabled' && echo true || echo false"]
        stdout: StdioCollector { id: wifiOut }
        onExited: { root.wifiEnabled = (wifiOut.text.trim() === "true"); }
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

    function refresh() {
        if (!getWifiStatus.running) getWifiStatus.running = true;
        if (!getBtStatus.running) getBtStatus.running = true;
        if (!getMicStatus.running) getMicStatus.running = true;
        if (!getAudioStatus.running) getAudioStatus.running = true;
    }

    // ==========================================
    // TOGGLES RAPIDES (Wi-Fi, Bluetooth, Micro, Audio)
    // ==========================================
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        // Toggle 1 : Wi-Fi
        Rectangle {
            Layout.fillWidth: true
            height: Math.round(Theme.relHeight(0.048, root.targetScreen))
            radius: Theme.radiusLarge
            color: root.wifiEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (wifiMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
            border.color: root.wifiEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.wifiEnabled ? Theme.backgroundSolid : Theme.textDisabled
                text: root.wifiEnabled ? "󰖩" : "󰖪"
            }

            MouseArea {
                id: wifiMouse
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
            height: Math.round(Theme.relHeight(0.048, root.targetScreen))
            radius: Theme.radiusLarge
            color: root.btEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (btMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
            border.color: root.btEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.btEnabled ? Theme.backgroundSolid : Theme.textDisabled
                text: root.btEnabled ? "󰂯" : "󰂲"
            }

            MouseArea {
                id: btMouse
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
            height: Math.round(Theme.relHeight(0.048, root.targetScreen))
            radius: Theme.radiusLarge
            color: !root.micMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (micMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
            border.color: !root.micMuted ? Theme.accent : Theme.destructive
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: !root.micMuted ? Theme.backgroundSolid : Theme.destructive
                text: !root.micMuted ? "󰍬" : "󰍭"
            }

            MouseArea {
                id: micMouse
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
            height: Math.round(Theme.relHeight(0.048, root.targetScreen))
            radius: Theme.radiusLarge
            color: !root.audioMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (audioMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
            border.color: !root.audioMuted ? Theme.accent : Theme.destructive
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: !root.audioMuted ? Theme.backgroundSolid : Theme.destructive
                text: !root.audioMuted ? "󰕾" : "󰝟"
            }

            MouseArea {
                id: audioMouse
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
    // BOUTONS D'ACTIONS SYSTÈME (Lock & Session)
    // ==========================================
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        // Verrouiller
        Rectangle {
            Layout.fillWidth: true
            height: Math.round(Theme.relHeight(0.034, root.targetScreen))
            radius: Theme.radiusMedium
            color: lockMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingSm
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.accent
                    text: "󰌾"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
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

        // Éteindre / Menu Session
        Rectangle {
            Layout.fillWidth: true
            height: Math.round(Theme.relHeight(0.034, root.targetScreen))
            radius: Theme.radiusMedium
            color: pwrMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.28) : Qt.rgba(1, 1, 1, 0.08)
            border.color: pwrMouse.containsMouse ? Theme.destructive : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingSm
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.destructive
                    text: "⏻"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
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
                onClicked: {
                    NotificationService.panelVisible = false;
                    SessionService.openSession();
                }
            }
        }
    }
}
