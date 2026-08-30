import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

ColumnLayout {
    id: root

    property var targetScreen: null
    spacing: Theme.spacingSm

    property int currentVolume: 50
    property int currentBrightness: 100
    property bool audioMuted: false

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

    function refresh() {
        if (!getVolumeVal.running) getVolumeVal.running = true;
        if (!getBrightVal.running) getBrightVal.running = true;
    }

    // Capsule Slider 1 : Volume
    Rectangle {
        id: volCapsule
        Layout.fillWidth: true
        height: 42
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
        border.width: 1
        clip: true

        // Remplissage progressif
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(1.0, root.currentVolume / 100.0)
            radius: parent.radius
            color: root.audioMuted ? Qt.rgba(1.0, 0.42, 0.42, 0.8) : Qt.rgba(0.365, 0.678, 0.886, 0.85)

            Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
        }

        // Éléments superposés (icône + pourcentage)
        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spacingMd
                rightMargin: Theme.spacingMd
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.currentVolume > 15 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.audioMuted ? "󰝟" : (root.currentVolume > 50 ? "󰕾" : "󰖀")
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: root.currentVolume > 85 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.currentVolume + "%"
            }
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

    // Capsule Slider 2 : Luminosité
    Rectangle {
        id: brightCapsule
        Layout.fillWidth: true
        height: 42
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
        border.width: 1
        clip: true

        // Remplissage progressif
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(1.0, root.currentBrightness / 100.0)
            radius: parent.radius
            color: Qt.rgba(0.365, 0.678, 0.886, 0.85)

            Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
        }

        // Éléments superposés (icône + pourcentage)
        RowLayout {
            anchors {
                fill: parent
                leftMargin: Theme.spacingMd
                rightMargin: Theme.spacingMd
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.currentBrightness > 15 ? Theme.backgroundSolid : Theme.textPrimary
                text: "󰃠"
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: root.currentBrightness > 85 ? Theme.backgroundSolid : Theme.textPrimary
                text: root.currentBrightness + "%"
            }
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
}
