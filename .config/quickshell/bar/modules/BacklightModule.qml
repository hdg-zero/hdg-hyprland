import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

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
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    // Popup paresseuse : voir CpuModule pour le détail du mécanisme LazyPopup.
    LazyPopup {
        id: lightLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            BacklightPopup {
                parentWindow: root.parentWindow
                anchorItem: root
                brightnessPercent: root.brightnessPercent
            }
        }
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

    Component.onCompleted: {
        getBrightness.running = true;
    }

    onScrolled: function(wheel) {
        var dy = (wheel && wheel.angleDelta && wheel.angleDelta.y !== undefined)
            ? wheel.angleDelta.y
            : ((wheel && wheel.delta !== undefined) ? wheel.delta : 0);

        if (dy > 0) {
            Quickshell.execDetached(["brightnessctl", "set", "+3%"]);
            root.brightnessPercent = Math.min(100, root.brightnessPercent + 3);
        } else if (dy < 0) {
            Quickshell.execDetached(["brightnessctl", "set", "3%-", "-n", "1%"]);
            root.brightnessPercent = Math.max(1, root.brightnessPercent - 3);
        }
    }

    onClicked: {
        lightLazy.toggle();
    }
}
