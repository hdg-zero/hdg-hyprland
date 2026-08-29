pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
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

    // Gestionnaire IPC pour contrôle externe (scripts & raccourcis Hyprland) : quickshell ipc call session toggle
    IpcHandler {
        target: "session"

        function toggle(): void {
            root.toggleSession();
        }

        function open(): void {
            root.openSession();
        }

        function close(): void {
            root.closeSession();
        }

        function lock(): void {
            root.lock();
        }

        function suspend(): void {
            root.suspend();
        }

        function logout(): void {
            root.logout();
        }

        function hibernate(): void {
            root.hibernate();
        }

        function reboot(): void {
            root.reboot();
        }

        function shutdown(): void {
            root.shutdown();
        }
    }
}
