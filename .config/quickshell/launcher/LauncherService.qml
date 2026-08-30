pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

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

    // Gestionnaire IPC dédié pour le lanceur.
    // NOTE (doc Quickshell Io/IpcHandler v0.3.x) : "Argument and return types must be
    // explicitly specified or they will not be registered." Sans « : void », les fonctions
    // ne sont pas enregistrées et `qs ipc call launcher toggle` échoue silencieusement.
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }
    }
}
