import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property var parentWindow: null
    property int brightnessPercent: 100

    readonly property var icons: ["", "", "", "󰃝", "󰃞", "󰃟", "󰃠"]

    icon: {
        var idx = Math.floor((brightnessPercent / 100) * (icons.length - 1));
        idx = Math.max(0, Math.min(icons.length - 1, idx));
        return icons[idx];
    }

    iconColor: Theme.accent
    text: brightnessPercent + "%"
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingMd
    customPaddingV: Theme.spacingSm

    BacklightPopup {
        id: lightPopup
        parentWindow: root.parentWindow
        anchorItem: root
        brightnessPercent: root.brightnessPercent
    }

    Process {
        id: getBrightness
        command: ["brightnessctl", "-m", "info"]
        stdout: StdioCollector {
            id: brightnessOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = brightnessOut.text.trim();
            var parts = str.split(",");
            if (parts.length >= 4) {
                var pct = parseInt(parts[3].replace("%", "")) || 0;
                root.brightnessPercent = pct;
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getBrightness.running) {
                getBrightness.running = true;
            }
        }
    }

    onScrolled: function(wheel) {
        if (wheel.angleDelta.y > 0) {
            Hyprland.dispatch("hl.dsp.exec_cmd('brightnessctl set +3%')");
            root.brightnessPercent = Math.min(100, root.brightnessPercent + 3);
        } else if (wheel.angleDelta.y < 0) {
            Hyprland.dispatch("hl.dsp.exec_cmd('brightnessctl set 3%- -n 1%')");
            root.brightnessPercent = Math.max(1, root.brightnessPercent - 3);
        }
    }

    onClicked: {
        lightPopup.toggle();
    }
}
