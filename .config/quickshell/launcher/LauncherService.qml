import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Applications

pragma Singleton

Singleton {
    id: root

    property bool launcherVisible: false

    function toggle() {
        launcherVisible = !launcherVisible;
    }

    function open() {
        launcherVisible = true;
    }

    function close() {
        launcherVisible = false;
    }

    // Gestionnaire IPC dédié pour le lanceur
    IpcHandler {
        target: "launcher"

        function toggle() {
            root.toggle();
        }

        function open() {
            root.open();
        }

        function close() {
            root.close();
        }
    }
}
