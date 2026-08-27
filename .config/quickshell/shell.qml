import Quickshell
import QtQuick
import "./theme"
import "./components"
import "./bar"

ShellRoot {
    id: root

    // Barre d'état native déployée dynamiquement sur chaque écran connecté
    Variants {
        model: Quickshell.screens

        BarWindow {}
    }
}
