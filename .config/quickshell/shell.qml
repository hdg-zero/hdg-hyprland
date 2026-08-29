import Quickshell
import QtQuick
import "./theme"
import "./components"
import "./bar"
import "./notifications"
import "./session"

ShellRoot {
    id: root

    // Barre d'état déployée dynamiquement sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        BarWindow {
            required property var modelData
            targetScreen: modelData
            screen: modelData
        }
    }

    // Toasts de notification sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        NotificationToastWindow {
            required property var modelData
            targetScreen: modelData
            screen: modelData
        }
    }

    // Centre de contrôle et notifications sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        NotificationCenter {
            required property var modelData
            targetScreen: modelData
            screen: modelData
        }
    }

    // Menu de session plein écran sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        SessionWindow {
            required property var modelData
            targetScreen: modelData
            screen: modelData
        }
    }
}
