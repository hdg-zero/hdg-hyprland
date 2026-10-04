import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../components"
import "../session"
import "./components"

PanelWindow {
    id: root

    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData

    // Détection de l'écran actuellement actif pour le routage exclusif du focus clavier.
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Hyprland/Hyprland/) :
    // Hyprland.focusedMonitor renvoie le moniteur ciblé, monitorFor(screen) résout l'écran Quickshell.
    readonly property bool isCurrentMonitor: {
        if (!root.screen) return true;
        var focused = Hyprland.focusedMonitor;
        var current = Hyprland.monitorFor(root.screen);
        return (focused && current) ? (focused.id === current.id) : true;
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Wayland/WlrKeyboardFocus/) :
    // WlrKeyboardFocus.Exclusive capture immédiatement les entrées clavier dès l'ouverture du panneau,
    // évitant de devoir cliquer manuellement sur le panneau pour saisir du texte.
    WlrLayershell.keyboardFocus: (visible && isCurrentMonitor) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
            Qt.callLater(scratchpad.focusEditor);
        } else {
            NotificationService.flushNotes();
        }
    }

    // Lazy loading : à la recréation par le Loader, la fenêtre naît déjà visible —
    // onVisibleChanged(false→true) ne part pas toujours. On rafraîchit donc aussi à la fin
    // de l'instanciation (états Wi-Fi/BT/micro, curseurs, notes et focus immédiat du scratchpad).
    Component.onCompleted: {
        if (visible) {
            refreshStatus();
            scratchpad.loadNotes();
            Qt.callLater(scratchpad.focusEditor);
        }
    }

    // Rafraîchissement initial à l'ouverture : l'état audio/volume étant désormais réactif
    // en direct via Quickshell.Services.Pipewire, tout polling périodique est éliminé.

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

    Rectangle {
        id: panelCard
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + Theme.spacingSm)
        width: Math.min(Theme.notificationPanelWidth, Math.max(0, parent.width - Theme.spacingLg * 2))
        height: Math.min(panelCol.implicitHeight + Theme.spacingLg * 2,
            Math.max(0, parent.height - anchors.topMargin - Theme.spacingLg))
        radius: 22
        border.color: Qt.rgba(1, 1, 1, 0.09)
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0; color: "#f516202a" }
            GradientStop { position: 1; color: "#fa0b0f14" }
        }
        clip: true

        // Les clics dans les espaces de la carte ne ferment pas le panneau.
        MouseArea { anchors.fill: parent }

        Flickable {
            id: panelScroll
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            contentWidth: width
            contentHeight: panelCol.implicitHeight
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: panelCol
                width: panelScroll.width
                spacing: Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingXs

                    PanelIconButton {
                        glyph: "󰌾"
                        description: "Verrouiller"
                        onClicked: {
                            NotificationService.panelVisible = false;
                            SessionService.lock();
                        }
                    }
                    PanelIconButton {
                        glyph: "⏻"
                        description: "Éteindre"
                        onClicked: {
                            NotificationService.panelVisible = false;
                            SessionService.shutdown();
                        }
                    }
                    Item { Layout.fillWidth: true }
                    PanelIconButton {
                        glyph: NotificationService.dnd ? "󰂛" : "󰂚"
                        description: "Ne pas déranger"
                        selected: NotificationService.dnd
                        onClicked: NotificationService.toggleDnd()
                    }
                    PanelIconButton {
                        glyph: "󰃢"
                        description: "Effacer les notifications"
                        enabled: NotificationService.unreadCount > 0
                        onClicked: NotificationService.clearAll()
                    }
                    PanelIconButton {
                        glyph: "󰅖"
                        description: "Fermer"
                        onClicked: NotificationService.panelVisible = false
                    }
                }

                QuickSettings {
                    id: quickSettings
                    targetScreen: root.screen
                    Layout.fillWidth: true
                }

                VolumeBrightnessSliders {
                    id: sliders
                    targetScreen: root.screen
                    Layout.fillWidth: true
                    audioMuted: quickSettings.audioMuted
                }

                NotificationList {
                    id: notifList
                    targetScreen: root.screen
                    Layout.fillWidth: true
                    // Le bloc-notes garde ses 40 % ; l'historique absorbe la variation.
                    maximumHeight: Math.max(80, Math.min(200,
                        Theme.relHeight(0.60, root.screen) - 450))
                }

                Scratchpad {
                    id: scratchpad
                    targetScreen: root.screen
                    Layout.fillWidth: true
                }
            }
        }
    }
}
