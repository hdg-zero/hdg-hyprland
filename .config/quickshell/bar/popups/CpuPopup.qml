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
    property string loadAvg: ""

    widthPercent: Theme.popupWidthPercentCompact
    cardHeight: mainCol.implicitHeight + Theme.spacingMd * 2

    Process {
        id: getCpuDetails
        command: ["sh", "-c", "cat /proc/loadavg | awk '{print $1, $2, $3}'; echo -n '|'; for t in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do if [ -f \"$t\" ]; then val=$(cat \"$t\" 2>/dev/null); if [ \"$val\" -gt 10000 ] && [ \"$val\" -lt 115000 ]; then echo -n $((val/1000))°C; break; fi; fi; done"]
        stdout: StdioCollector {
            id: cpuOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = cpuOut.text.trim();
            if (!str) return;
            var sections = str.split("|");
            if (sections.length >= 1) root.loadAvg = sections[0].trim();
            if (sections.length >= 2 && sections[1].trim().length > 0) root.cpuTemp = sections[1].trim();
        }
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getCpuDetails.running) {
                getCpuDetails.running = true;
            }
        }
    }

    onVisibleChanged: {
        if (visible && !getCpuDetails.running) {
            getCpuDetails.running = true;
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

        // En-tête compact
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: "󰻠"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: "Processeur"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: root.cpuPercent + "%"
            }
        }

        // Barre d'utilisation
        Rectangle {
            Layout.fillWidth: true
            height: Theme.spacingXs
            radius: Theme.radiusSmall / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.cpuPercent)) / 100.0)
                height: parent.height
                radius: Theme.radiusSmall / 2
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Métriques discrètes
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                visible: root.cpuTemp !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: " " + root.cpuTemp
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: root.loadAvg !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: " " + root.loadAvg
            }
        }
    }
}
