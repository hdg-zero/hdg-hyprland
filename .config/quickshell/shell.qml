import Quickshell
import QtQuick
import "./theme"
import "./components"
import "./bar"
import "./notifications"

ShellRoot {
    id: root

    // Barre d'état et fenêtres de notifications déployées dynamiquement sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        Scope {
            required property var modelData

            BarWindow {
                targetScreen: modelData
            }

            NotificationToastWindow {
                targetScreen: modelData
            }

            NotificationCenter {
                targetScreen: modelData
            }
        }
    }
}
