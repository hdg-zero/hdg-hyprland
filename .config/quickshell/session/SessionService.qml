pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Service centralisé des actions système de session (verrouillage, mise en veille, extinction).
// Pilotable via Quickshell et via IPC (quickshell ipc call session lock/shutdown/...)
// Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Io/IpcHandler/)
Singleton {
    id: root

    function lock() {
        Quickshell.execDetached(["loginctl", "lock-session"]);
    }

    function suspend() {
        Quickshell.execDetached(["sh", "-c", "loginctl lock-session && systemctl suspend"]);
    }

    function logout() {
        Quickshell.execDetached(["uwsm", "stop"]);
    }

    function hibernate() {
        Quickshell.execDetached(["systemctl", "hibernate"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    // Gestionnaire IPC typé pour contrôle externe (scripts & raccourcis Hyprland)
    IpcHandler {
        target: "session"

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
