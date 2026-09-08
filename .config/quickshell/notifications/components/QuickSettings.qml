import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import "../../theme"
import "../../session"
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

    // ==========================================
    // TOGGLES RAPIDES (Wi-Fi, Bluetooth, Micro, Audio)
    // ==========================================
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        // Toggle 1 : Wi-Fi
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: Theme.radiusLarge
            color: root.wifiEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (wifiMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
            border.color: root.wifiEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: root.wifiEnabled ? Theme.backgroundSolid : Theme.textDisabled
                text: root.wifiEnabled ? "󰖩" : "󰖪"
            }

            MouseArea {
                id: wifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var nextState = !Networking.wifiEnabled;
                    Networking.wifiEnabled = nextState;
                    // Repli défensif rfkill en tâche de fond si disponible
                    Quickshell.execDetached(["sh", "-c", "command -v rfkill >/dev/null 2>&1 && rfkill " + (nextState ? "unblock" : "block") + " wifi || true"]);
                }
            }
        }

        // Toggle 2 : Bluetooth
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: Theme.radiusLarge
            color: root.btEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (btMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
            border.color: root.btEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
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

        // Toggle 3 : Caféine (Anti-sommeil)
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: Theme.radiusLarge
            color: CaffeineService.active ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (caffeineMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
            border.color: CaffeineService.active ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: CaffeineService.active ? Theme.backgroundSolid : Theme.textDisabled
                text: CaffeineService.active ? "󰅶" : "󰾪"
            }

            MouseArea {
                id: caffeineMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    CaffeineService.toggle();
                }
            }
        }

        // Toggle 4 : Micro
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: Theme.radiusLarge
            color: !root.micMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (micMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
            border.color: !root.micMuted ? Theme.accent : Theme.destructive
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: !root.micMuted ? Theme.backgroundSolid : Theme.destructive
                text: !root.micMuted ? "󰍬" : "󰍭"
            }

            MouseArea {
                id: micMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.source && root.source.audio && root.source.audio.muted !== undefined) {
                        root.source.audio.muted = !root.source.audio.muted;
                    } else {
                        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                    }
                }
            }
        }

        // Toggle 5 : Mute Audio
        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: Theme.radiusLarge
            color: !root.audioMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (audioMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
            border.color: !root.audioMuted ? Theme.accent : Theme.destructive
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: !root.audioMuted ? Theme.backgroundSolid : Theme.destructive
                text: !root.audioMuted ? "󰕾" : "󰝟"
            }

            MouseArea {
                id: audioMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
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

    // ==========================================
    // BOUTONS D'ACTIONS SYSTÈME (Lock & Session)
    // ==========================================
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSm

        // Verrouiller
        Rectangle {
            Layout.fillWidth: true
            height: 40
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
                onClicked: {
                    NotificationService.panelVisible = false;
                    SessionService.lock();
                }
            }
        }

        // Éteindre rapidement
        Rectangle {
            Layout.fillWidth: true
            height: 40
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
                    text: "Éteindre"
                }
            }

            MouseArea {
                id: pwrMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    NotificationService.panelVisible = false;
                    SessionService.shutdown();
                }
            }
        }
    }
}
