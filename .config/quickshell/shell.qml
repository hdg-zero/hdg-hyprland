import Quickshell
import QtQuick
import "./theme"
import "./components"
import "./bar"
import "./notifications"
import "./session"

ShellRoot {
    id: root

    // Barre d'état, notifications et menu de session déployés dynamiquement sur chaque écran connecté
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

            SessionWindow {
                targetScreen: modelData
            }
        }
    }
}
