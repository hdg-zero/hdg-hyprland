import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications as Notifs
import "../theme"
import "../components"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        right: true
    }

    margins {
        top: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + Theme.spacingSm)
        right: Math.round(Theme.spacingSm + Theme.spacingXs)
    }

    implicitWidth: Math.round(Theme.relWidth(0.125, root.screen))
    implicitHeight: Math.min(Math.round(Theme.relHeight(0.85, root.screen)), panelCard.implicitHeight)

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: {
            NotificationService.panelVisible = false;
        }
    }

    Keys.onEscapePressed: function(event) {
        NotificationService.panelVisible = false;
        event.accepted = true;
    }

    visible: NotificationService.panelVisible

    // États matériels
    property bool wifiEnabled: true
    property string wifiSsid: ""
    property bool btEnabled: true
    property bool micMuted: false
    property bool audioMuted: false
    property int currentVolume: 50
    property int currentBrightness: 100

    // États du Bloc-Notes
    property bool notesLoaded: false

    Process {
        id: getWifiStatus
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null | grep -q 'enabled' && echo true || echo false"]
        stdout: StdioCollector { id: wifiOut }
        onExited: { root.wifiEnabled = (wifiOut.text.trim() === "true"); }
    }

    Process {
        id: getBtStatus
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo true || echo false"]
        stdout: StdioCollector { id: btOut }
        onExited: { root.btEnabled = (btOut.text.trim() === "true"); }
    }

    Process {
        id: getMicStatus
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo true || echo false"]
        stdout: StdioCollector { id: micOut }
        onExited: { root.micMuted = (micOut.text.trim() === "true"); }
    }

    Process {
        id: getAudioStatus
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo true || echo false"]
        stdout: StdioCollector { id: audioOut }
        onExited: { root.audioMuted = (audioOut.text.trim() === "true"); }
    }

    Process {
        id: getVolumeVal
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}'"]
        stdout: StdioCollector { id: volOut }
        onExited: {
            var v = parseInt(volOut.text.trim());
            if (!isNaN(v)) root.currentVolume = v;
        }
    }

    Process {
        id: getBrightVal
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%'"]
        stdout: StdioCollector { id: brightOut }
        onExited: {
            var b = parseInt(brightOut.text.trim());
            if (!isNaN(b)) root.currentBrightness = b;
        }
    }

    // Chargement persistant des notes
    Process {
        id: loadNotesProc
        command: ["sh", "-c", "mkdir -p \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell\" && cat \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/scratchpad.txt\" 2>/dev/null || echo ''"]
        stdout: StdioCollector { id: notesOut }
        onExited: {
            if (!root.notesLoaded) {
                notesEdit.text = notesOut.text;
                root.notesLoaded = true;
            }
        }
    }

    // Sauvegarde automatique temporisée des notes
    Timer {
        id: saveNotesTimer
        interval: 400
        repeat: false
        onTriggered: {
            var txt = notesEdit.text;
            Quickshell.execDetached(["sh", "-c", "mkdir -p \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell\" && printf '%s' \"$1\" > \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/scratchpad.txt\"", "--", txt]);
        }
    }

    function refreshStatus() {
        if (!getWifiStatus.running) getWifiStatus.running = true;
        if (!getBtStatus.running) getBtStatus.running = true;
        if (!getMicStatus.running) getMicStatus.running = true;
        if (!getAudioStatus.running) getAudioStatus.running = true;
        if (!getVolumeVal.running) getVolumeVal.running = true;
        if (!getBrightVal.running) getBrightVal.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            refreshStatus();
            if (!root.notesLoaded && !loadNotesProc.running) {
                loadNotesProc.running = true;
            }
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

    // Carte principale en Glassmorphism Frost & Obsidian Glass
    Rectangle {
        id: panelCard
        width: parent.width
        implicitHeight: panelCol.implicitHeight + Theme.spacingMd * 2
        radius: Theme.radiusXLarge
        color: Qt.rgba(0.06, 0.08, 0.12, 0.75)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
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
                    width: Math.round(Theme.relHeight(0.030, root.screen))
                    height: width
                    radius: width / 2
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
                    width: Math.round(Theme.relHeight(0.030, root.screen))
                    height: width
                    radius: width / 2
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
                    width: Math.round(Theme.relHeight(0.030, root.screen))
                    height: width
                    radius: width / 2
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
            // 2. TOGGLES RAPIDES (Style Apple Control Center - 100% Relatif)
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // Toggle 1 : Wi-Fi
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.048, root.screen))
                    radius: Theme.radiusLarge
                    color: root.wifiEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (wifiMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
                    border.color: root.wifiEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: root.wifiEnabled ? Theme.backgroundSolid : Theme.textDisabled
                        text: root.wifiEnabled ? "󰖩" : "󰖪"
                    }

                    MouseArea {
                        id: wifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "nmcli radio wifi " + (root.wifiEnabled ? "off" : "on")]);
                            root.wifiEnabled = !root.wifiEnabled;
                            getWifiStatus.running = true;
                        }
                    }
                }

                // Toggle 2 : Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.048, root.screen))
                    radius: Theme.radiusLarge
                    color: root.btEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (btMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))
                    border.color: root.btEnabled ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: root.btEnabled ? Theme.backgroundSolid : Theme.textDisabled
                        text: root.btEnabled ? "󰂯" : "󰂲"
                    }

                    MouseArea {
                        id: btMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "bluetoothctl power " + (root.btEnabled ? "off" : "on")]);
                            root.btEnabled = !root.btEnabled;
                            getBtStatus.running = true;
                        }
                    }
                }

                // Toggle 3 : Micro
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.048, root.screen))
                    radius: Theme.radiusLarge
                    color: !root.micMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (micMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
                    border.color: !root.micMuted ? Theme.accent : Theme.destructive
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: !root.micMuted ? Theme.backgroundSolid : Theme.destructive
                        text: !root.micMuted ? "󰍬" : "󰍭"
                    }

                    MouseArea {
                        id: micMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                            root.micMuted = !root.micMuted;
                            getMicStatus.running = true;
                        }
                    }
                }

                // Toggle 4 : Mute Audio
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.048, root.screen))
                    radius: Theme.radiusLarge
                    color: !root.audioMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.85) : (audioMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.35) : Qt.rgba(1.0, 0.42, 0.42, 0.22))
                    border.color: !root.audioMuted ? Theme.accent : Theme.destructive
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: !root.audioMuted ? Theme.backgroundSolid : Theme.destructive
                        text: !root.audioMuted ? "󰕾" : "󰝟"
                    }

                    MouseArea {
                        id: audioMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                            root.audioMuted = !root.audioMuted;
                            getAudioStatus.running = true;
                        }
                    }
                }
            }

            // ==========================================
            // 3. CURSEURS EN CAPSULE (Style Apple macOS Control Center - 100% Relatif)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // Capsule Slider 1 : Volume
                Rectangle {
                    id: volCapsule
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.038, root.screen))
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1
                    clip: true

                    // Remplissage progressif
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * Math.min(1.0, root.currentVolume / 100.0)
                        radius: parent.radius
                        color: root.audioMuted ? Qt.rgba(1.0, 0.42, 0.42, 0.8) : Qt.rgba(0.365, 0.678, 0.886, 0.85)

                        Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
                    }

                    // Éléments superposés (icône + pourcentage)
                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingMd
                            rightMargin: Theme.spacingMd
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold: true
                            color: root.currentVolume > 15 ? Theme.backgroundSolid : Theme.textPrimary
                            text: root.audioMuted ? "󰝟" : (root.currentVolume > 50 ? "󰕾" : "󰖀")
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: root.currentVolume > 85 ? Theme.backgroundSolid : Theme.textPrimary
                            text: root.currentVolume + "%"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        function setVol(mouseX) {
                            var pct = Math.max(0, Math.min(100, Math.round((mouseX / width) * 100)));
                            root.currentVolume = pct;
                            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
                        }
                        onPressed: function(mouse) { setVol(mouse.x); }
                        onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x); }
                    }
                }

                // Capsule Slider 2 : Luminosité
                Rectangle {
                    id: brightCapsule
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.038, root.screen))
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1
                    clip: true

                    // Remplissage progressif
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * Math.min(1.0, root.currentBrightness / 100.0)
                        radius: parent.radius
                        color: Qt.rgba(0.365, 0.678, 0.886, 0.85)

                        Behavior on width { NumberAnimation { duration: Theme.animDurationFast / 2 } }
                    }

                    // Éléments superposés (icône + pourcentage)
                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: Theme.spacingMd
                            rightMargin: Theme.spacingMd
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold: true
                            color: root.currentBrightness > 15 ? Theme.backgroundSolid : Theme.textPrimary
                            text: "󰃠"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: root.currentBrightness > 85 ? Theme.backgroundSolid : Theme.textPrimary
                            text: root.currentBrightness + "%"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        function setBright(mouseX) {
                            var pct = Math.max(5, Math.min(100, Math.round((mouseX / width) * 100)));
                            root.currentBrightness = pct;
                            Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
                        }
                        onPressed: function(mouse) { setBright(mouse.x); }
                        onPositionChanged: function(mouse) { if (pressed) setBright(mouse.x); }
                    }
                }
            }

            // ==========================================
            // 4. BOUTONS D'ACTIONS SYSTÈME (Lock & Session)
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // Verrouiller
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.034, root.screen))
                    radius: Theme.radiusMedium
                    color: lockMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.accent
                            text: "󰌾"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Verrouiller"
                        }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["hyprlock"]); }
                    }
                }

                // Éteindre / Menu Wlogout
                Rectangle {
                    Layout.fillWidth: true
                    height: Math.round(Theme.relHeight(0.034, root.screen))
                    radius: Theme.radiusMedium
                    color: pwrMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.28) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: pwrMouse.containsMouse ? Theme.destructive : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.destructive
                            text: "⏻"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Session"
                        }
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["wlogout"]); }
                    }
                }
            }

            // Séparateur fin
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
            }

            // ==========================================
            // 5. HISTORIQUE DES NOTIFICATIONS
            // ==========================================
            RowLayout {
                Layout.fillWidth: true

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textSecondary
                    text: "Notifications"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    width: Math.round(Theme.fontSizeLarge)
                    height: width
                    radius: width / 2
                    color: Theme.accent

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMicro
                        font.bold: true
                        color: Theme.backgroundSolid
                        text: NotificationService.unreadCount.toString()
                    }
                }
            }

            // Liste défilante des notifications
            Item {
                Layout.fillWidth: true
                implicitHeight: NotificationService.unreadCount === 0 ? Math.round(Theme.relHeight(0.030, root.screen)) : Math.min(Math.round(Theme.relHeight(0.20, root.screen)), notifList.contentHeight)
                clip: true

                // État vide minimaliste
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: NotificationService.unreadCount === 0
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDisabled
                        text: "Aucune notification"
                    }
                }

                // Vue Liste
                ListView {
                    id: notifList
                    anchors.fill: parent
                    visible: NotificationService.unreadCount > 0
                    model: (NotificationService.trackedNotifications && NotificationService.trackedNotifications.values) ? NotificationService.trackedNotifications.values : []
                    clip: true
                    spacing: Theme.spacingSm

                    delegate: Rectangle {
                        id: notifCard
                        required property var modelData
                        width: notifList.width
                        implicitHeight: cardInnerCol.implicitHeight + Theme.spacingMd * 2
                        radius: Theme.radiusLarge
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.color: cardHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                        border.width: 1

                        Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                        MouseArea {
                            id: cardHover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }

                        ColumnLayout {
                            id: cardInnerCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: Theme.spacingMd
                            }
                            spacing: Theme.spacingXs

                            // En-tête de la notification
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingSm

                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.accent
                                    text: modelData.appName || "Application"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    width: Math.round(Theme.fontSizeLarge)
                                    height: width
                                    radius: width / 2
                                    color: itemDelMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.3) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeTiny
                                        color: itemDelMouse.containsMouse ? Theme.destructive : Theme.textDisabled
                                        text: "󰅖"
                                    }

                                    MouseArea {
                                        id: itemDelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            NotificationService.dismissNotification(modelData);
                                        }
                                    }
                                }
                            }

                            // Titre
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.textPrimary
                                text: modelData.summary || ""
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Corps
                            Text {
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                                text: modelData.body || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Boutons d'actions
                            RowLayout {
                                Layout.fillWidth: true
                                visible: modelData.actions && modelData.actions.values && modelData.actions.values.length > 0
                                spacing: Theme.spacingSm
                                Layout.topMargin: Theme.spacingXs

                                Repeater {
                                    model: modelData.actions ? modelData.actions.values : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitWidth: actLabel.implicitWidth + Theme.spacingMd * 2
                                        implicitHeight: Math.round(Theme.relHeight(0.024, root.screen))
                                        radius: Theme.radiusSmall
                                        color: actBtnMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)
                                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                        border.width: 1

                                        Text {
                                            id: actLabel
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeTiny
                                            font.bold: true
                                            color: actBtnMouse.containsMouse ? Theme.backgroundSolid : Theme.textPrimary
                                            text: modelData.text || "Action"
                                        }

                                        MouseArea {
                                            id: actBtnMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData && typeof modelData.invoke === "function") {
                                                    modelData.invoke();
                                                }
                                                NotificationService.dismissNotification(notifCard.modelData);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // 6. MINI BLOC-NOTES RAPIDE (Scratchpad Glassmorphic)
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textSecondary
                    text: "Bloc-Notes"
                }

                Item { Layout.fillWidth: true }

                // Bouton Copier dans le presse-papier
                Rectangle {
                    width: Math.round(Theme.fontSizeLarge)
                    height: width
                    radius: width / 2
                    color: copyNotesMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        color: copyNotesMouse.containsMouse ? Theme.accent : Theme.textSecondary
                        text: "󰆏"
                    }

                    MouseArea {
                        id: copyNotesMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "--", notesEdit.text]);
                        }
                    }
                }

                // Bouton Effacer notes
                Rectangle {
                    width: Math.round(Theme.fontSizeLarge)
                    height: width
                    radius: width / 2
                    color: clearNotesMouse.containsMouse ? Qt.rgba(1.0, 0.42, 0.42, 0.3) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        color: clearNotesMouse.containsMouse ? Theme.destructive : Theme.textDisabled
                        text: "󰃢"
                    }

                    MouseArea {
                        id: clearNotesMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            notesEdit.text = "";
                            saveNotesTimer.restart();
                        }
                    }
                }
            }

            // Zone d'édition du bloc-notes
            Rectangle {
                Layout.fillWidth: true
                height: Math.round(Theme.relHeight(0.11, root.screen))
                radius: Theme.radiusMedium
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: notesEdit.activeFocus ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    onClicked: {
                        notesEdit.forceActiveFocus();
                    }
                }

                Flickable {
                    id: notesFlickable
                    anchors.fill: parent
                    anchors.margins: Theme.spacingSm
                    contentWidth: width
                    contentHeight: Math.max(height, notesEdit.implicitHeight)
                    clip: true

                    TextEdit {
                        id: notesEdit
                        width: notesFlickable.width
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.textPrimary
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.backgroundSolid
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        activeFocusOnPress: true

                        Keys.onEscapePressed: function(event) {
                            NotificationService.panelVisible = false;
                            event.accepted = true;
                        }

                        Text {
                            anchors.fill: parent
                            visible: !notesEdit.text && !notesEdit.activeFocus
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.textDisabled
                            text: "Noter rapidement quelque chose..."
                        }

                        onTextChanged: {
                            if (root.notesLoaded) {
                                saveNotesTimer.restart();
                            }
                        }
                    }
                }
            }
        }
    }
}
