import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: SessionService.sessionVisible

    // Horloge temps réel
    property string currentTime: ""
    property string currentDate: ""
    property string uptimeStr: ""

    Process {
        id: getClockProc
        command: ["date", "+%H:%M|%A %d %B %Y"]
        stdout: StdioCollector { id: clockOut }
        onExited: {
            var parts = clockOut.text.trim().split("|");
            if (parts.length === 2) {
                root.currentTime = parts[0];
                var d = parts[1];
                root.currentDate = d.charAt(0).toUpperCase() + d.slice(1);
            }
        }
    }

    Process {
        id: getUptimeProc
        command: ["sh", "-c", "uptime -p 2>/dev/null | sed 's/up //g' || echo ''"]
        stdout: StdioCollector { id: uptimeOut }
        onExited: {
            root.uptimeStr = uptimeOut.text.trim();
        }
    }

    function refreshInfo() {
        if (!getClockProc.running) getClockProc.running = true;
        if (!getUptimeProc.running) getUptimeProc.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            refreshInfo();
        }
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: root.refreshInfo()
    }

    // Raccourcis clavier directs
    Shortcut { sequence: "Escape"; enabled: root.visible; onActivated: SessionService.closeSession() }
    Shortcut { sequence: "L"; enabled: root.visible; onActivated: SessionService.lock() }
    Shortcut { sequence: "l"; enabled: root.visible; onActivated: SessionService.lock() }
    Shortcut { sequence: "U"; enabled: root.visible; onActivated: SessionService.suspend() }
    Shortcut { sequence: "u"; enabled: root.visible; onActivated: SessionService.suspend() }
    Shortcut { sequence: "E"; enabled: root.visible; onActivated: SessionService.logout() }
    Shortcut { sequence: "e"; enabled: root.visible; onActivated: SessionService.logout() }
    Shortcut { sequence: "H"; enabled: root.visible; onActivated: SessionService.hibernate() }
    Shortcut { sequence: "h"; enabled: root.visible; onActivated: SessionService.hibernate() }
    Shortcut { sequence: "R"; enabled: root.visible; onActivated: SessionService.reboot() }
    Shortcut { sequence: "r"; enabled: root.visible; onActivated: SessionService.reboot() }
    Shortcut { sequence: "S"; enabled: root.visible; onActivated: SessionService.shutdown() }
    Shortcut { sequence: "s"; enabled: root.visible; onActivated: SessionService.shutdown() }

    // Fond en verre dépoli sombre plein écran
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.03, 0.04, 0.06, 0.85)

        Behavior on opacity { NumberAnimation { duration: Theme.animDurationNormal } }

        // Clic sur l'arrière-plan pour fermer
        MouseArea {
            anchors.fill: parent
            onClicked: SessionService.closeSession()
        }

        // Bouton de fermeture en haut à droite
        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                margins: Theme.spacingXl
            }
            width: Math.round(Theme.relHeight(0.045, root.screen))
            height: width
            radius: width / 2
            color: closeMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.3) : Qt.rgba(1, 1, 1, 0.08)
            border.color: closeMouse.containsMouse ? Theme.destructive : Qt.rgba(1.0, 1.0, 1.0, 0.15)
            border.width: 1

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: closeMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                text: "󰅖"
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: SessionService.closeSession()
            }
        }

        // Conteneur centré principal
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Math.round(Theme.relHeight(0.045, root.screen))

            // En-tête : Horloge & Date
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacingXs

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.fontSizeTitle * 2.2)
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.currentTime
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.accentSecondary
                    text: root.currentDate
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.uptimeStr !== ""
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.textDisabled
                    text: "Actif depuis " + root.uptimeStr
                }
            }

            // Rangée de cartes d'actions de session
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacingLg

                Repeater {
                    model: [
                        { label: "Verrouiller", icon: "󰌾", key: "L", color: Theme.accent, action: function() { SessionService.lock(); } },
                        { label: "Veille", icon: "󰤄", key: "U", color: Theme.accentSecondary, action: function() { SessionService.suspend(); } },
                        { label: "Déconnexion", icon: "󰍃", key: "E", color: Theme.warning, action: function() { SessionService.logout(); } },
                        { label: "Hiberner", icon: "󰋊", key: "H", color: Theme.textSecondary, action: function() { SessionService.hibernate(); } },
                        { label: "Redémarrer", icon: "󰜉", key: "R", color: Theme.warning, action: function() { SessionService.reboot(); } },
                        { label: "Éteindre", icon: "⏻", key: "S", color: Theme.destructive, action: function() { SessionService.shutdown(); } }
                    ]

                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        required property int index

                        implicitWidth: Math.round(Theme.relWidth(0.085, root.screen))
                        implicitHeight: Math.round(Theme.relHeight(0.18, root.screen))
                        radius: Theme.radiusXLarge

                        color: cardMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                        border.color: cardMouse.containsMouse ? modelData.color : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                        border.width: cardMouse.containsMouse ? 2 : 1

                        scale: cardMouse.containsMouse ? 1.06 : 1.0

                        Behavior on scale { NumberAnimation { duration: Theme.animDurationFast; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingMd
                            spacing: Theme.spacingSm

                            Item { Layout.fillHeight: true }

                            // Icône principale
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: Math.round(Theme.fontSizeTitle * 1.8)
                                color: cardMouse.containsMouse ? modelData.color : Theme.textPrimary
                                text: modelData.icon

                                Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }
                            }

                            // Libellé de l'action
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: cardMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                                text: modelData.label
                            }

                            Item { Layout.fillHeight: true }

                            // Badge indicateur du raccourci clavier
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: Math.round(Theme.fontSizeLarge * 1.5)
                                height: Math.round(Theme.fontSizeMedium * 1.3)
                                radius: Theme.radiusSmall
                                color: cardMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(1, 1, 1, 0.08)
                                border.color: cardMouse.containsMouse ? modelData.color : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeTiny
                                    font.bold: true
                                    color: cardMouse.containsMouse ? modelData.color : Theme.textDisabled
                                    text: modelData.key
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.action()
                        }
                    }
                }
            }

            // Message d'aide
            Text {
                Layout.alignment: Qt.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.textDisabled
                text: "Appuyez sur une touche ou [Échap] pour annuler"
            }
        }
    }
}
