import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property int memPercent: 0
    property string memUsedGb: "0"
    property string memTotalGb: "0"

    icon: "󰍛"
    iconColor: memPercent > 85 ? Theme.destructive : (memPercent > 70 ? Theme.warning : Theme.accent)
    text: memPercent + "% RAM"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    widthPercent: Theme.moduleWidthPercentMetrics

    MemoryPopup {
        id: memPopup
        parentWindow: root.parentWindow
        anchorItem: root
        ramPercent: root.memPercent
    }

    FileView {
        id: procMeminfo
        path: "/proc/meminfo"
        watchChanges: false
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procMeminfo.reload();
            var content = typeof procMeminfo.text === "function" ? procMeminfo.text() : (procMeminfo.text || "");
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
    }

    onClicked: {
        memPopup.toggle();
    }

    onRightClicked: {
        Quickshell.execDetached(["kitty", "--title", "btop", "-e", "btop"]);
    }
}
