import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"
import "../popups"

PillButton {
    id: root

    property int cpuUsage: 0
    property var lastTotal: 0
    property var lastIdle: 0

    icon: "󰻠"
    iconColor: cpuUsage > 80 ? Theme.destructive : (cpuUsage > 50 ? Theme.warning : Theme.accent)
    text: cpuUsage + "% CPU"
    customPaddingH: Theme.spacingSm
    customPaddingV: 1
    widthPercent: Theme.moduleWidthPercentMetrics

    // Popup paresseuse : instanciée au premier survol (140 ms) ou clic, détruite après
    // l'animation de fermeture (économie de RAM : pas de surface Wayland/GPU au repos).
    LazyPopup {
        id: cpuLazy
        targetWindow: root.parentWindow
        anchor: root
        popupComponent: Component {
            CpuPopup {
                parentWindow: root.parentWindow
                anchorItem: root
                cpuPercent: root.cpuUsage
            }
        }
    }

    FileView {
        id: procStat
        path: "/proc/stat"
        watchChanges: false
        blockAllReads: true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            procStat.reload();
            var content = procStat.text();
            if (!content) return;

            var firstLine = content.split("\n")[0];
            var parts = firstLine.trim().split(/\s+/);
            if (parts.length >= 5 && parts[0] === "cpu") {
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var steal = parseInt(parts[8]) || 0;

                var total = user + nice + system + idle + iowait + irq + softirq + steal;
                var currentIdle = idle + iowait;

                if (root.lastTotal > 0) {
                    var totalDelta = total - root.lastTotal;
                    var idleDelta = currentIdle - root.lastIdle;
                    if (totalDelta > 0) {
                        var usage = Math.round(((totalDelta - idleDelta) / totalDelta) * 100);
                        root.cpuUsage = Math.max(0, Math.min(100, usage));
                    }
                }

                root.lastTotal = total;
                root.lastIdle = currentIdle;
            }
        }
    }

    onClicked: {
        cpuLazy.toggle();
    }

    onRightClicked: {
        Quickshell.execDetached(["kitty", "--title", "btop", "-e", "btop"]);
    }
}
