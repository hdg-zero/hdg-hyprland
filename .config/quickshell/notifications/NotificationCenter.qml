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
        bottom: true
        right: true
    }

    margins {
        top: Math.round(Theme.relHeight(Theme.barHeightRatio, root.screen) + 6)
        bottom: Theme.spacingMd
        right: Theme.spacingMd
    }

    implicitWidth: Theme.relWidth(0.20, root.screen)

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    visible: NotificationService.panelVisible

    // État des Toggles Rapides
    property bool wifiEnabled: true
    property bool btEnabled: true
    property bool micMuted: false
    property bool audioMuted: false
    property int currentVolume: 50
    property int currentBrightness: 100

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

    // Carte principale du panneau
    Rectangle {
        id: panelCard
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.cardBackgroundSolid
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingMd

            // 1. En-tête : Titre, DND, Effacer tout, Fermer
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHeader
                    color: Theme.accent
                    text: "󰂚"
                }

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Centre de Contrôle"
                }

                // Bouton Ne Pas Déranger (DND)
                Rectangle {
                    width: 28
                    height: 28
                    radius: Theme.radiusSmall
                    color: NotificationService.dnd ? Qt.rgba(1.0, 0.72, 0.42, 0.25) : (dndMouse.containsMouse ? Theme.cardBackgroundHover : "transparent")
                    border.color: NotificationService.dnd ? Theme.warning : (dndMouse.containsMouse ? Theme.glassBorder : "transparent")
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
                        onClicked: {
                            NotificationService.toggleDnd();
                        }
                    }
                }

                // Bouton Effacer tout
                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    implicitWidth: clearText.implicitWidth + Theme.spacingSm * 2
                    height: 28
                    radius: Theme.radiusSmall
                    color: clearMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"
                    border.color: clearMouse.containsMouse ? Theme.glassBorder : "transparent"
                    border.width: 1

                    RowLayout {
                        id: clearText
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                            text: "󰃢"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.textSecondary
                            text: "Effacer"
                        }
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            NotificationService.clearAll();
                        }
                    }
                }

                // Bouton Fermer le panneau
                Rectangle {
                    width: 28
                    height: 28
                    radius: Theme.radiusSmall
                    color: closePanelMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: closePanelMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary
                        text: "󰅖"
                    }

                    MouseArea {
                        id: closePanelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            NotificationService.panelVisible = false;
                        }
                    }
                }
            }

            // 2. Grille des Toggles Rapides (2 lignes x 3 colonnes)
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: Theme.spacingSm
                columnSpacing: Theme.spacingSm

                // Toggle WiFi
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: root.wifiEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : Theme.cardBackgroundHover
                    border.color: root.wifiEnabled ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: root.wifiEnabled ? Theme.accent : Theme.textDisabled
                            text: root.wifiEnabled ? "󰖩" : "󰖪"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: root.wifiEnabled ? Theme.textPrimary : Theme.textSecondary
                            text: "Wi-Fi"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "nmcli radio wifi " + (root.wifiEnabled ? "off" : "on")]);
                            root.wifiEnabled = !root.wifiEnabled;
                        }
                    }
                }

                // Toggle Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: root.btEnabled ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : Theme.cardBackgroundHover
                    border.color: root.btEnabled ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: root.btEnabled ? Theme.accent : Theme.textDisabled
                            text: root.btEnabled ? "󰂯" : "󰂲"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: root.btEnabled ? Theme.textPrimary : Theme.textSecondary
                            text: "BT"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", "bluetoothctl power " + (root.btEnabled ? "off" : "on")]);
                            root.btEnabled = !root.btEnabled;
                        }
                    }
                }

                // Toggle Micro
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: !root.micMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : Theme.cardBackgroundHover
                    border.color: !root.micMuted ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: !root.micMuted ? Theme.accent : Theme.destructive
                            text: !root.micMuted ? "󰍬" : "󰍭"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Micro"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                            root.micMuted = !root.micMuted;
                        }
                    }
                }

                // Toggle Mute Audio
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: !root.audioMuted ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : Theme.cardBackgroundHover
                    border.color: !root.audioMuted ? Theme.accent : Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: !root.audioMuted ? Theme.accent : Theme.destructive
                            text: !root.audioMuted ? "󰕾" : "󰝟"
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: true
                            color: Theme.textPrimary
                            text: "Audio"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                            root.audioMuted = !root.audioMuted;
                        }
                    }
                }

                // Toggle Verrou (hyprlock)
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: Theme.cardBackgroundHover
                    border.color: Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
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
                            text: "Lock"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["hyprlock"]);
                        }
                    }
                }

                // Toggle Éteindre / Menu Énergie
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: Theme.radiusMedium
                    color: Theme.cardBackgroundHover
                    border.color: Theme.glassBorderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
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
                            text: "Power"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["wlogout"]);
                        }
                    }
                }
            }

            // 3. Curseurs Rapides (Volume & Luminosité)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                // Slider Volume
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.audioMuted ? Theme.destructive : Theme.accent
                        text: root.audioMuted ? "󰝟" : "󰕾"
                    }

                    Rectangle {
                        id: volSlider
                        Layout.fillWidth: true
                        height: Theme.progressBarHeight
                        radius: Theme.progressBarHeight / 2
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            height: parent.height
                            width: parent.width * Math.min(1.0, root.currentVolume / 100.0)
                            radius: Theme.progressBarHeight / 2
                            color: root.audioMuted ? Theme.destructive : Theme.accent
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

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textSecondary
                        text: root.currentVolume + "%"
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Slider Luminosité
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accent
                        text: "󰃠"
                    }

                    Rectangle {
                        id: brightSlider
                        Layout.fillWidth: true
                        height: Theme.progressBarHeight
                        radius: Theme.progressBarHeight / 2
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            height: parent.height
                            width: parent.width * Math.min(1.0, root.currentBrightness / 100.0)
                            radius: Theme.progressBarHeight / 2
                            color: Theme.accent
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

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textSecondary
                        text: root.currentBrightness + "%"
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // Séparateur
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.glassBorder
            }

            // 4. Section Notifications
            RowLayout {
                Layout.fillWidth: true

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Notifications (" + NotificationService.unreadCount + ")"
                }
            }

            // Liste des notifications défilante
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // État vide
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: NotificationService.unreadCount === 0
                    spacing: Theme.spacingSm

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTitle + 8
                        color: Qt.rgba(1, 1, 1, 0.15)
                        text: "󰂚"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDisabled
                        text: "Aucune notification"
                    }
                }

                // Vue liste
                ListView {
                    id: notifList
                    anchors.fill: parent
                    visible: NotificationService.unreadCount > 0
                    model: (NotificationService.trackedNotifications && NotificationService.trackedNotifications.values) ? NotificationService.trackedNotifications.values : []
                    clip: true
                    spacing: Theme.spacingSm

                    delegate: Rectangle {
                        id: notifItem
                        required property var modelData
                        width: notifList.width
                        implicitHeight: itemCol.implicitHeight + Theme.spacingSm * 2
                        radius: Theme.radiusMedium
                        color: Theme.cardBackgroundHover
                        border.color: Theme.glassBorderSubtle
                        border.width: 1

                        ColumnLayout {
                            id: itemCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: Theme.spacingSm
                            }
                            spacing: Theme.spacingXs

                            // En-tête de l'item
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingSm

                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.accent
                                    text: modelData.appName || "Application"
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Bouton supprimer
                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: width / 2
                                    color: delMouse.containsMouse ? Theme.cardBackground : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeTiny
                                        color: delMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                                        text: "󰅖"
                                    }

                                    MouseArea {
                                        id: delMouse
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
                                font.pixelSize: Theme.fontSizeTiny
                                color: Theme.textSecondary
                                text: modelData.body || ""
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            // Actions
                            RowLayout {
                                Layout.fillWidth: true
                                visible: modelData.actions && modelData.actions.values && modelData.actions.values.length > 0
                                spacing: Theme.spacingXs

                                Repeater {
                                    model: modelData.actions ? modelData.actions.values : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitWidth: actTxt.implicitWidth + Theme.spacingSm * 2
                                        implicitHeight: 20
                                        radius: Theme.radiusSmall
                                        color: actMouse.containsMouse ? Theme.accent : Theme.cardBackground
                                        border.color: Theme.glassBorder
                                        border.width: 1

                                        Text {
                                            id: actTxt
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeTiny
                                            font.bold: true
                                            color: actMouse.containsMouse ? Theme.backgroundSolid : Theme.textPrimary
                                            text: modelData.text || "Action"
                                        }

                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData && typeof modelData.invoke === "function") {
                                                    modelData.invoke();
                                                }
                                                NotificationService.dismissNotification(notifItem.modelData);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
