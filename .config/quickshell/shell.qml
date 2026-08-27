import Quickshell
import QtQuick
import QtQuick.Layouts
import "./theme"
import "./components"

ShellRoot {
    id: root

    // Fenêtre test/placeholder de fondation pour l'étape 0
    PanelWindow {
        id: testWindow

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 38
        color: Theme.background

        GlassCard {
            anchors.fill: parent
            customColor: Theme.background
            customBorderColor: Theme.glassBorder
            customRadius: 0

            RowLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingMd

                IconLabel {
                    icon: ""
                    text: "Quickshell 0.3.1 — Fondations initialisées"
                    iconColor: Theme.accent
                    textColor: Theme.textPrimary
                    textBold: true
                }

                PillButton {
                    icon: "󰄬"
                    text: "Obsidian & Glacier Blue"
                    active: true
                }
            }
        }
    }
}
