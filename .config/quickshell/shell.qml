import Quickshell
import QtQuick
import "./theme"
import "./components"
import "./bar"
import "./notifications"
import "./session"
import "./launcher"

ShellRoot {
    id: root

    // Lanceur d'applications natif (Obsidian Glass)
    Variants {
        model: Quickshell.screens

        LauncherWindow {
            targetScreen: modelData
        }
    }

    // Barre d'état déployée dynamiquement sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        BarWindow {
            targetScreen: modelData
        }
    }

    // Toasts de notification sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        NotificationToastWindow {
            targetScreen: modelData
        }
    }

    // Centre de contrôle et notifications sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        NotificationCenter {
            targetScreen: modelData
        }
    }

    // Menu de session plein écran sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        SessionWindow {
            targetScreen: modelData
        }
    }
}
