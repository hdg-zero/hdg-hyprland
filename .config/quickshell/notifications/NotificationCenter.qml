import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "../session"
import "./components"

PanelWindow {
    id: root

    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "qs-panel"

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: {
            NotificationService.panelVisible = false;
        }
    }

    visible: NotificationService.panelVisible

    function refreshStatus() {
        quickSettings.refresh();
        sliders.refresh();
    }

    onVisibleChanged: {
        if (visible) {
            refreshStatus();
            scratchpad.loadNotes();
        }
    }

    // Lazy loading : à la recréation par le Loader, la fenêtre naît déjà visible —
    // onVisibleChanged(false→true) ne part pas toujours. On rafraîchit donc aussi à la fin
    // de l'instanciation (états Wi-Fi/BT/micro, curseurs, notes du scratchpad).
    Component.onCompleted: {
        if (visible) {
            refreshStatus();
            scratchpad.loadNotes();
        }
    }

    Timer {
        interval: 3000
        running: root.visible
        repeat: true
        onTriggered: {
            root.refreshStatus();
        }
    }

    // Fond assombri dismissible au clic
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.03, 0.05, 0.50)

        MouseArea {
            anchors.fill: parent
            onClicked: {
                NotificationService.panelVisible = false;
            }
        }
    }

    // Carte principale centrée horizontalement en haut de l'écran en Glassmorphism Obsidian Glass
    Rectangle {
        id: panelCard
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + Theme.spacingSm)
        width: Theme.notificationPanelWidth
        implicitHeight: panelCol.implicitHeight + Theme.spacingMd * 2
        radius: Theme.radiusXLarge
        color: Qt.rgba(0.043, 0.059, 0.078, 0.94) // Obsidian Glass haute opacité
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        ColumnLayout {
            id: panelCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacingMd
            }
            spacing: Theme.spacingSm

            // ==========================================
            // 1. BOUTONS D'ACTION HAUT (DND, Effacer, Fermer)
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                Item { Layout.fillWidth: true }

                // Bouton Ne Pas Déranger (DND)
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: NotificationService.dnd ? Qt.rgba(1.0, 0.72, 0.42, 0.3) : (dndMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08))
                    border.color: NotificationService.dnd ? Theme.warning : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: NotificationService.dnd ? Theme.warning : Theme.textSecondary
                        text: NotificationService.dnd ? "󰂛" : "󰂚"
                    }

                    MouseArea {
                        id: dndMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.toggleDnd(); }
                    }
                }

                // Bouton Effacer tout
                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    width: 30
                    height: 30
                    radius: 15
                    color: clearMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.3) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: clearMouse.containsMouse ? Theme.destructive : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: clearMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                        text: "󰃢"
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.clearAll(); }
                    }
                }

                // Bouton Fermer le panneau
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closePanelMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: closePanelMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                        text: "󰅖"
                    }

                    MouseArea {
                        id: closePanelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { NotificationService.panelVisible = false; }
                    }
                }
            }

            // ==========================================
            // 2. TOGGLES RAPIDES & ACTIONS SYSTÈME
            // ==========================================
            QuickSettings {
                id: quickSettings
                targetScreen: root.screen
                Layout.fillWidth: true
            }

            // ==========================================
            // 3. CURSEURS EN CAPSULE (Volume & Luminosité)
            // ==========================================
            VolumeBrightnessSliders {
                id: sliders
                targetScreen: root.screen
                Layout.fillWidth: true
                audioMuted: quickSettings.audioMuted
            }

            // Séparateur fin
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
            }

            // ==========================================
            // 4. HISTORIQUE DES NOTIFICATIONS
            // ==========================================
            NotificationList {
                id: notifList
                targetScreen: root.screen
                Layout.fillWidth: true
            }

            // Séparateur fin
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
            }

            // ==========================================
            // 5. MINI BLOC-NOTES RAPIDE (Scratchpad)
            // ==========================================
            Scratchpad {
                id: scratchpad
                targetScreen: root.screen
                Layout.fillWidth: true
            }
        }
    }
}
