import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "../../theme"
import "../../components"

PillButton {
    id: root

    property int unreadCount: 0
    property bool dnd: false

    icon: dnd ? "󰂛" : (unreadCount > 0 ? "󱅫" : "󰂚")
    iconColor: dnd ? Theme.warning : (unreadCount > 0 ? Theme.accent : Theme.textSecondary)
    text: unreadCount > 0 ? unreadCount.toString() : ""
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingMd
    customPaddingV: Theme.spacingSm

    Process {
        id: swayncStatus
        command: ["swaync-client", "-c"]
        stdout: StdioCollector {
            id: swayncOut
        }
        onExited: function(exitCode, exitStatus) {
            var count = parseInt(swayncOut.text.trim()) || 0;
            root.unreadCount = count;
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!swayncStatus.running) {
                swayncStatus.running = true;
            }
        }
    }

    onClicked: {
        Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
        if (!swayncStatus.running) {
            swayncStatus.running = true;
        }
    }

    onRightClicked: {
        Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
        root.dnd = !root.dnd;
    }
}
