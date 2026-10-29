import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import ".."
import "../components"

BarPillButton {
    id: root

    property int memPercent: 0
    property string memUsedGb: "0"
    property string memTotalGb: "0"

    icon: "󰍛"
    iconColor: memPercent > 85 ? BarStyle.destructive : (memPercent > 70 ? BarStyle.warning : BarStyle.accentText)
    text: memPercent + "%"
    description: "RAM · " + text + " · clic droit : btop"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    customWidth: BarStyle.metricWidth(screenWidth)



    FileView {
        id: procMeminfo
        path: "/proc/meminfo"
        watchChanges: false
        preload: true
        onLoaded: root.consumeMemoryStats()
    }

    function consumeMemoryStats() {
        var content = procMeminfo.text();
        if (!content) return;

        var totalKb = 0;
        var availKb = 0;

        var lines = content.split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (line.indexOf("MemTotal:") === 0) {
                var parts = line.split(/\s+/);
                totalKb = parseInt(parts[1]) || 0;
            } else if (line.indexOf("MemAvailable:") === 0) {
                var parts = line.split(/\s+/);
                availKb = parseInt(parts[1]) || 0;
            }
            if (totalKb > 0 && availKb > 0) break;
        }

        if (totalKb > 0) {
            var usedKb = totalKb - availKb;
            root.memPercent = Math.round((usedKb / totalKb) * 100);
            root.memUsedGb = (usedKb / (1024 * 1024)).toFixed(1);
            root.memTotalGb = (totalKb / (1024 * 1024)).toFixed(1);
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: procMeminfo.reload()
    }


    onRightClicked: {
        Quickshell.execDetached(["kitty", "--title", "btop", "-e", "btop"]);
    }
}
