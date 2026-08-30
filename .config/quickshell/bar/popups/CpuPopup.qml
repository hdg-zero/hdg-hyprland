import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int cpuPercent: 0
    property string cpuTemp: ""
    property var coreList: []
    property var prevCores: ({})

    widthPercent: Theme.popupWidthPercentStandard
    cardHeight: mainCol.implicitHeight + Theme.spacingMd * 2

    property string tempSensorPath: ""

    Process {
        id: findTempSensor
        command: ["sh", "-c", "for t in /sys/class/hwmon/hwmon*/temp*_input /sys/class/thermal/thermal_zone*/temp; do if [ -f \"$t\" ]; then echo -n \"$t\"; break; fi; done"]
        stdout: StdioCollector {
            id: tempPathOut
        }
        onExited: function(exitCode, exitStatus) {
            var path = tempPathOut.text.trim();
            if (path) {
                root.tempSensorPath = path;
                root.updateCpuTemp();
            }
        }
    }

    FileView {
        id: tempFile
        path: root.tempSensorPath
        watchChanges: false
        blockAllReads: true
    }

    function updateCpuTemp() {
        if (!root.tempSensorPath) return;
        tempFile.reload();
        var val = parseInt(tempFile.text().trim()) || 0;
        if (val > 10000 && val < 115000) {
            root.cpuTemp = Math.round(val / 1000) + "°C";
        }
    }

    FileView {
        id: procStatFile
        path: "/proc/stat"
        watchChanges: false
        blockAllReads: true
    }

    function updateCpuStats() {
        procStatFile.reload();
        var txt = procStatFile.text();
        if (!txt) return;

        var lines = txt.split("\n");
        var newCores = [];

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line) continue;

            var parts = line.split(/\s+/);
            var name = parts[0];

            if (name === "cpu") {
                // Global CPU
                var u = parseInt(parts[1]) || 0;
                var n = parseInt(parts[2]) || 0;
                var s = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var io = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var sirq = parseInt(parts[7]) || 0;
                var steal = parseInt(parts[8]) || 0;

                var total = u + n + s + idle + io + irq + sirq + steal;
                var idleTotal = idle + io;

                if (root.prevCores["global"]) {
                    var dTotal = total - root.prevCores["global"].total;
                    var dIdle = idleTotal - root.prevCores["global"].idle;
                    if (dTotal > 0) {
                        root.cpuPercent = Math.max(0, Math.min(100, Math.round((1 - (dIdle / dTotal)) * 100)));
                    }
                }
                root.prevCores["global"] = { total: total, idle: idleTotal };
            } else if (name.match(/^cpu\d+$/)) {
                // Per-core
                var coreId = parseInt(name.replace("cpu", "")) || 0;
                var cu = parseInt(parts[1]) || 0;
                var cn = parseInt(parts[2]) || 0;
                var cs = parseInt(parts[3]) || 0;
                var cidle = parseInt(parts[4]) || 0;
                var cio = parseInt(parts[5]) || 0;
                var cirq = parseInt(parts[6]) || 0;
                var csirq = parseInt(parts[7]) || 0;
                var csteal = parseInt(parts[8]) || 0;

                var cTotal = cu + cn + cs + cidle + cio + cirq + csirq + csteal;
                var cIdleTotal = cidle + cio;
                var cPct = 0;

                if (root.prevCores[name]) {
                    var cdTotal = cTotal - root.prevCores[name].total;
                    var cdIdle = cIdleTotal - root.prevCores[name].idle;
                    if (cdTotal > 0) {
                        cPct = Math.max(0, Math.min(100, Math.round((1 - (cdIdle / cdTotal)) * 100)));
                    }
                }
                root.prevCores[name] = { total: cTotal, idle: cIdleTotal };
                newCores.push({ id: coreId, percent: cPct });
            }
        }

        if (newCores.length > 0) {
            root.coreList = newCores;
        }
    }

    Component.onCompleted: {
        findTempSensor.running = true;
    }

    Timer {
        interval: 1500
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.updateCpuStats();
            root.updateCpuTemp();
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.updateCpuStats();
            root.updateCpuTemp();
        }
    }

    ColumnLayout {
        id: mainCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête : CPU % et Température
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: "󰻠"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Processeur"
            }

            Text {
                visible: root.cpuTemp !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: " " + root.cpuTemp
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                font.bold: true
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: root.cpuPercent + "%"
            }
        }

        // Barre d'utilisation globale (plus épaisse)
        Rectangle {
            Layout.fillWidth: true
            height: Theme.progressBarHeight
            radius: Theme.progressBarHeight / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.cpuPercent)) / 100.0)
                height: parent.height
                radius: Theme.progressBarHeight / 2
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Séparateur fin
        Rectangle {
            visible: root.coreList.length > 0
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Grille des cœurs avec barres plus visibles
        GridLayout {
            Layout.fillWidth: true
            columns: root.coreList.length > 8 ? 4 : 2
            rowSpacing: Theme.spacingXs
            columnSpacing: Theme.spacingMd

            Repeater {
                model: root.coreList

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Theme.spacingXs

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                        text: "C" + modelData.id
                        Layout.preferredWidth: Theme.spacingLg
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: Theme.progressBarMiniHeight
                        radius: Theme.progressBarMiniHeight / 2
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            width: parent.width * (Math.min(100, Math.max(0, modelData.percent)) / 100.0)
                            height: parent.height
                            radius: Theme.progressBarMiniHeight / 2
                            color: modelData.percent > 80 ? Theme.destructive : (modelData.percent > 50 ? Theme.warning : Theme.accent)

                            Behavior on width {
                                NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                            }
                        }
                    }

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: modelData.percent > 80 ? Theme.destructive : (modelData.percent > 50 ? Theme.warning : Theme.textPrimary)
                        text: modelData.percent + "%"
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: Theme.spacingXl
                    }
                }
            }
        }
    }
}
