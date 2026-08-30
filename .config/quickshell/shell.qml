import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./theme"
import "./components"
import "./bar"
import "./notifications"
import "./session"
import "./launcher"

ShellRoot {
    id: root

    // Maintien en vie du lanceur après fermeture : laisse l'animation de sortie (160 ms)
    // se jouer avant que le Loader ne détruise la fenêtre et sa surface Wayland.
    property bool launcherKeepAlive: false

    function isFocusedScreen(screen) {
        if (!screen) return false;
        if (!Hyprland.focusedMonitor) return true;
        return screen.name === Hyprland.focusedMonitor.name;
    }

    Timer {
        id: launcherKeepAliveTimer
        interval: 300
        onTriggered: root.launcherKeepAlive = false
    }

    Connections {
        target: LauncherService
        function onLauncherVisibleChanged() {
            if (!LauncherService.launcherVisible) {
                root.launcherKeepAlive = true;
                launcherKeepAliveTimer.restart();
            } else {
                launcherKeepAliveTimer.stop();
                root.launcherKeepAlive = false;
            }
        }
    }

    // La barre d'état reste permanente : surface visible en continu, une destruction/
    // recréation n'amortirait rien et ferait scintiller les écrans à chaque reload.
    Variants {
        model: Quickshell.screens

        BarWindow {
            targetScreen: modelData
        }
    }

    // ---- Fenêtres secondaires paresseuses -------------------------------------------
    // Chaque fenêtre (surface Wayland + contexts GPU) n'est instanciée que lorsque son
    // service l'exige sur l'écran actif, puis détruite (economie RAM/GPU au repos : le shell
    // au démarrage ne crée qu'une seule surface par écran, la barre).

    // Lanceur : monté tant que demandé + 300 ms après fermeture (anim de sortie 160 ms).
    Variants {
        model: Quickshell.screens

        Loader {
            required property var modelData
            active: (LauncherService.launcherVisible || root.launcherKeepAlive) && root.isFocusedScreen(modelData)

            sourceComponent: LauncherWindow {
                targetScreen: modelData
            }
        }
    }

    // Menu de session plein écran (pas d'animation de sortie : destruction immédiate).
    Variants {
        model: Quickshell.screens

        Loader {
            required property var modelData
            active: SessionService.sessionVisible && root.isFocusedScreen(modelData)
            sourceComponent: SessionWindow {
                targetScreen: modelData
            }
        }
    }

    // Centre de contrôle & notifications.
    Variants {
        model: Quickshell.screens

        Loader {
            required property var modelData
            active: NotificationService.panelVisible && root.isFocusedScreen(modelData)
            sourceComponent: NotificationCenter {
                targetScreen: modelData
            }
        }
    }

    // Toasts de notification (fenêtre existante tant qu'un toast est affiché).
    Variants {
        model: Quickshell.screens

        Loader {
            required property var modelData
            active: NotificationService.activeToasts.length > 0 && root.isFocusedScreen(modelData)
            sourceComponent: NotificationToastWindow {
                targetScreen: modelData
            }
        }
    }
}
