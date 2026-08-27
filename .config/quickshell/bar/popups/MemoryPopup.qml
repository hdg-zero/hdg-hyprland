import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
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

    property var topMemProcesses: []

    cardWidth: 290
    cardHeight: memCol.implicitHeight + Theme.spacingMd * 2

    Process {
        id: getMemDetails
        command: ["sh", "-c", "cat /proc/meminfo | awk '{print $1\":\"$2}'; echo '---'; ps -eo pid,comm,%mem --sort=-%mem --no-headers | head -n 5 | awk '{print $1\":\"$2\":\"$3}'"]
        stdout: StdioCollector {
            id: memOut
        }
        onExited: function(exitCode, exitStatus) {
            var str = memOut.text.trim();
            if (!str) return;

            var sections = str.split("---");
            if (sections.length >= 1) {
                var lines = sections[0].trim().split("\n");
                var memTotal = 0;
                var memAvail = 0;
                var swapTotal = 0;
                var swapFree = 0;

                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 2) {
                        var k = parts[0].trim();
                        var v = parseInt(parts[1].trim()) || 0;
                        if (k === "MemTotal") memTotal = v;
                        else if (k === "MemAvailable") memAvail = v;
                        else if (k === "SwapTotal") swapTotal = v;
                        else if (k === "SwapFree") swapFree = v;
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

            if (sections.length >= 2) {
                var procs = [];
                var procLines = sections[1].trim().split("\n");
                for (var j = 0; j < procLines.length; j++) {
                    var p = procLines[j].trim().split(":");
                    if (p.length >= 3) {
                        procs.push({ pid: p[0], name: p[1], mem: p[2] });
                    }
                }
                root.topMemProcesses = procs;
            }
        }
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getMemDetails.running) {
                getMemDetails.running = true;
            }
        }
    }

    onVisibleChanged: {
        if (visible && !getMemDetails.running) {
            getMemDetails.running = true;
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
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)
                text: "󰍛"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Mémoire Vive (RAM)"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)
                text: root.ramPercent + "%"
            }
        }

        // Barre d'utilisation RAM
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.ramPercent)) / 100.0)
                height: parent.height
                radius: 3
                color: root.ramPercent > 85 ? Theme.destructive : (root.ramPercent > 70 ? Theme.warning : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Détail RAM (Utilisé / Total)
        RowLayout {
            Layout.fillWidth: true
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "Utilisation RAM :"
            }
            Item { Layout.fillWidth: true }
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.ramUsedFormatted + " / " + root.ramTotalFormatted
            }
        }

        // Section SWAP
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingXs
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "󰓡 Swap :"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.swapUsedFormatted + " / " + root.swapTotalFormatted
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: root.swapPercent > 50 ? Theme.warning : Theme.textSecondary
                text: root.swapPercent + "%"
            }
        }

        // Barre d'utilisation Swap
        Rectangle {
            Layout.fillWidth: true
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.swapPercent)) / 100.0)
                height: parent.height
                radius: 2
                color: root.swapPercent > 50 ? Theme.warning : Theme.accentSecondary
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

        // Section Top Processus Mémoire
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textSecondary
            text: "Top Processus Mémoire"
        }

        Repeater {
            model: root.topMemProcesses

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
                    color: Theme.accentSecondary
                    text: modelData.mem + "%"
                }
            }
        }

        // Bouton Ouvrir btop
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingSm
            height: 28
            radius: Theme.radiusMedium
            color: memBtopMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
            border.color: Theme.glassBorder
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingXs

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.accentSecondary
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
                id: memBtopMouse
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
