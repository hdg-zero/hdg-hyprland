import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int ramPercent: 0
    property string ramUsedFormatted: "0 Go"
    property string ramTotalFormatted: "0 Go"

    property int swapPercent: 0
    property string swapUsedFormatted: "0 Go"
    property string swapTotalFormatted: "0 Go"

    widthPercent: Theme.popupWidthPercentCompact
    cardHeight: memCol.implicitHeight + Theme.spacingMd * 2

    FileView {
        id: meminfoFile
        path: "/proc/meminfo"
        watchChanges: false
    }

    function updateMemoryStats() {
        meminfoFile.reload();
        var txt = typeof meminfoFile.text === "function" ? meminfoFile.text() : (meminfoFile.text || "");
        if (!txt) return;

        var lines = txt.split("\n");
        var memTotal = 0;
        var memAvail = 0;
        var swapTotal = 0;
        var swapFree = 0;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line) continue;

            var match = line.match(/^(\w+):\s*(\d+)/);
            if (match) {
                var key = match[1];
                var val = parseInt(match[2]) || 0; // in kB
                if (key === "MemTotal") memTotal = val;
                else if (key === "MemAvailable") memAvail = val;
                else if (key === "SwapTotal") swapTotal = val;
                else if (key === "SwapFree") swapFree = val;
            }
        }

        if (memTotal > 0) {
            var memUsed = memTotal - memAvail;
            root.ramPercent = Math.round((memUsed / memTotal) * 100);
            root.ramUsedFormatted = (memUsed / (1024 * 1024)).toFixed(1) + " Go";
            root.ramTotalFormatted = (memTotal / (1024 * 1024)).toFixed(1) + " Go";
        }

        if (swapTotal > 0) {
            var swapUsed = swapTotal - swapFree;
            root.swapPercent = Math.round((swapUsed / swapTotal) * 100);
            root.swapUsedFormatted = (swapUsed / (1024 * 1024)).toFixed(1) + " Go";
            root.swapTotalFormatted = (swapTotal / (1024 * 1024)).toFixed(1) + " Go";
        } else {
            root.swapPercent = 0;
            root.swapUsedFormatted = "0 Go";
            root.swapTotalFormatted = "0 Go";
        }
    }

    Timer {
        interval: 1500
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.updateMemoryStats();
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.updateMemoryStats();
        }
    }

    ColumnLayout {
        id: memCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête RAM
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)
                text: "󰍛"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Mémoire"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                font.bold: true
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)
                text: root.ramPercent + "%"
            }
        }

        // Barre d'utilisation RAM (plus épaisse)
        Rectangle {
            Layout.fillWidth: true
            height: Theme.progressBarHeight
            radius: Theme.progressBarHeight / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.ramPercent)) / 100.0)
                height: parent.height
                radius: Theme.progressBarHeight / 2
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Métriques RAM & Swap
        RowLayout {
            Layout.fillWidth: true

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: root.ramUsedFormatted + " / " + root.ramTotalFormatted
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: root.swapPercent > 0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDisabled
                text: "Swap: " + root.swapPercent + "%"
            }
        }
    }
}
