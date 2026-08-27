pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool sessionVisible: false

    function toggleSession() {
        root.sessionVisible = !root.sessionVisible;
    }

    function openSession() {
        root.sessionVisible = true;
    }

    function closeSession() {
        root.sessionVisible = false;
    }

    function lock() {
        root.closeSession();
        Quickshell.execDetached(["hyprlock"]);
    }

    function suspend() {
        root.closeSession();
        Quickshell.execDetached(["sh", "-c", "loginctl lock-session && systemctl suspend"]);
    }

    function logout() {
        root.closeSession();
        Quickshell.execDetached(["uwsm", "stop"]);
    }

    function hibernate() {
        root.closeSession();
        Quickshell.execDetached(["systemctl", "hibernate"]);
    }

    function reboot() {
        root.closeSession();
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown() {
        root.closeSession();
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    // Gestionnaire IPC pour contrôle externe (scripts & raccourcis Hyprland)
    IpcHandler {
        target: "session"

        handler: function(cmd) {
            if (cmd === "toggle") {
                root.toggleSession();
            } else if (cmd === "open") {
                root.openSession();
            } else if (cmd === "close") {
                root.closeSession();
            } else if (cmd === "lock") {
                root.lock();
            } else if (cmd === "suspend") {
                root.suspend();
            } else if (cmd === "logout") {
                root.logout();
            } else if (cmd === "hibernate") {
                root.hibernate();
            } else if (cmd === "reboot") {
                root.reboot();
            } else if (cmd === "shutdown") {
                root.shutdown();
            }
        }
    }
}
