pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function toggle(): void {
        setActive(!root.active);
    }

    function enable(): void {
        setActive(true);
    }

    function disable(): void {
        setActive(false);
    }

    function setActive(val: bool): void {
        if (root.active === val) return;
        root.active = val;
        syncState();
    }

    function syncState(): void {
        var stateStr = root.active ? "enabled" : "disabled";
        Quickshell.execDetached(["sh", "-c", "mkdir -p \"${XDG_RUNTIME_DIR:-/tmp}\" && printf '%s' " + stateStr + " > \"${XDG_RUNTIME_DIR:-/tmp}/caffeine.state\""]);

        if (root.active) {
            // Rétablissement de l'affichage si l'écran était atténué ou éteint
            Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.dpms({ action = 'enable' })"]);
            Quickshell.execDetached(["brightnessctl", "-r"]);
            Quickshell.execDetached(["notify-send", "-a", "Caffeine", "-u", "normal", "☕ Mode Caféine activé", "L'écran ne se mettra plus en veille."]);
        } else {
            Quickshell.execDetached(["notify-send", "-a", "Caffeine", "-u", "normal", "☕ Mode Caféine désactivé", "Gestion normale de l'inactivité rétablie."]);
        }
    }

    // Gestionnaire IPC dédié pour le mode caféine (quickshell ipc call caffeine toggle)
    IpcHandler {
        target: "caffeine"

        function toggle(): void {
            root.toggle();
        }

        function enable(): void {
            root.enable();
        }

        function disable(): void {
            root.disable();
        }

        function status(): string {
            return root.active ? "enabled" : "disabled";
        }
    }
}
