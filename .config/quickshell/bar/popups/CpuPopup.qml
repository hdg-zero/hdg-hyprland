import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property int cpuPercent: 0
    property string cpuTemp: "N/A"
    property string loadAvg: ""
    property var topProcesses: []

    cardWidth: 290
    cardHeight: mainCol.implicitHeight + Theme.spacingMd * 2

    // Récupération des informations détaillées uniquement quand le popup est ouvert
    Process {
        id: getCpuDetails
        command: ["sh", "-c", "echo -n $(cat /proc/loadavg | awk '{print $1, $2, $3}'); echo -n '|'; for t in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do if [ -f \"$t\" ]; then val=$(cat \"$t\" 2>/dev/null); if [ \"$val\" -gt 10000 ] && [ \"$val\" -lt 115000 ]; then echo -n $((val/1000))°C; break; fi; fi; done; echo -n '|'; ps -eo pid,comm,%cpu --sort=-%cpu --no-headers | head -n 5 | awk '{print $1\":\"$2\":\"$3}'"]
        stdout: StdioCollector {
            id: cpuOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = cpuOut.text.trim();
            if (!str) return;
            var sections = str.split("|");
            if (sections.length >= 1) root.loadAvg = sections[0].trim();
            if (sections.length >= 2 && sections[1].trim().length > 0) root.cpuTemp = sections[1].trim();
            if (sections.length >= 3) {
                var procs = [];
                var lines = sections[2].trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim().split(":");
                    if (p.length >= 3) {
                        procs.push({ pid: p[0], name: p[1], cpu: p[2] });
                    }
                }
                root.topProcesses = procs;
            }
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

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: "󰻠"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Processeur (CPU)"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)
                text: root.cpuPercent + "%"
            }
        }

        // Barre d'utilisation
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.cpuPercent)) / 100.0)
                height: parent.height
                radius: 3
                color: root.cpuPercent > 80 ? Theme.destructive : (root.cpuPercent > 50 ? Theme.warning : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Métriques (Température + Load Avg)
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingXs

            RowLayout {
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                    text: " Temp :"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.cpuTemp
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                    text: " Load :"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.loadAvg || "N/A"
                }
            }
        }

        // Séparateur
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
            Layout.topMargin: Theme.spacingXs
            Layout.bottomMargin: Theme.spacingXs
        }

        // Section Top Processus
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textSecondary
            text: "Top Processus CPU"
        }

        Repeater {
            model: root.topProcesses

            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textPrimary
                    text: modelData.name
                    elide: Text.ElideRight
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.accent
                    text: modelData.cpu + "%"
                }
            }
        }

        // Bouton Ouvrir btop
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingSm
            height: 28
            radius: Theme.radiusMedium
            color: btopMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
            border.color: Theme.glassBorder
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingXs

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.accent
                    text: "󰆍"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Moniteur Système (btop)"
                }
            }

            MouseArea {
                id: btopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["kitty", "--title", "btop", "-e", "btop"]);
                    root.close();
                }
            }
        }
    }
}
