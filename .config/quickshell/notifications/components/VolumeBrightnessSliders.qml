import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../theme"
import "../"

Rectangle {
    id: root

    property var targetScreen: null
    implicitHeight: 84
    radius: Theme.radiusLarge
    color: NotificationStyle.surface

    // Suivi réactif natif PipeWire pour le volume
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    // Volume synchronisé en temps réel avec PipeWire
    readonly property int currentVolume: (audio && audio.volume !== undefined)
        ? Math.round(audio.volume * 100)
        : fallbackVolume
    property int fallbackVolume: 50

    property int currentBrightness: 100
    property bool audioMuted: false

    // Debounce pour l'ajustement de luminosité (évite d'inonder le système de forks brightnessctl pendant le drag)
    Timer {
        id: brightDebounce
        interval: 40
        repeat: false
        property int pendingPct: 100
        onTriggered: {
            Quickshell.execDetached(["brightnessctl", "set", pendingPct + "%"]);
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

    function refresh() {
        if (!getBrightVal.running) getBrightVal.running = true;
    }

    component PanelSlider: Slider {
        id: control
        from: 0
        to: 100
        stepSize: 1
        implicitHeight: 34
        leftPadding: 6
        rightPadding: 6
        focusPolicy: Qt.StrongFocus
        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: 5
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.07)
            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: NotificationStyle.accent
            }
        }
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: 12
            height: 12
            radius: 6
            color: NotificationStyle.handle
            border.width: control.activeFocus ? 2 : 0
            border.color: NotificationStyle.accent
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        anchors.topMargin: Theme.spacingSm
        anchors.bottomMargin: Theme.spacingSm
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.audioMuted ? Theme.destructive : Theme.textSecondary
                text: root.audioMuted ? "󰝟" : "󰕾"
            }
            PanelSlider {
                Layout.fillWidth: true
                value: root.currentVolume
                Accessible.name: "Volume"
                onMoved: {
                    if (root.audio && root.audio.volume !== undefined) {
                        root.audio.volume = value / 100.0;
                    } else {
                        root.fallbackVolume = Math.round(value);
                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"]);
                    }
                }
            }
            Text {
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
                font.family: NotificationStyle.fontFamily
                font.pixelSize: Theme.fontSizeMicro
                color: Theme.textSecondary
                text: root.currentVolume + " %"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.textSecondary
                text: "󰃠"
            }
            PanelSlider {
                Layout.fillWidth: true
                from: 5
                value: root.currentBrightness
                Accessible.name: "Luminosité"
                onMoved: {
                    root.currentBrightness = Math.round(value);
                    brightDebounce.pendingPct = Math.round(value);
                    brightDebounce.restart();
                }
            }
            Text {
                Layout.preferredWidth: 38
                horizontalAlignment: Text.AlignRight
                font.family: NotificationStyle.fontFamily
                font.pixelSize: Theme.fontSizeMicro
                color: Theme.textSecondary
                text: root.currentBrightness + " %"
            }
        }
    }
}
