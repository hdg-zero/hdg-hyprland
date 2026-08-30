import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../"

ColumnLayout {
    id: root

    property var targetScreen: null
    property bool notesLoaded: false
    spacing: Theme.spacingSm

    // Chargement persistant des notes via FileView (doc Quickshell.Io/FileView v0.3.x :
    // setText() est atomique ; statePath() fournit le répertoire d'état par shell).
    FileView {
        id: notesFile
        path: Quickshell.statePath("scratchpad.txt")
        printErrors: false   // premier lancement : fichier absent, ne pas polluer les logs

        onLoaded: {
            if (!root.notesLoaded) {
                notesEdit.text = notesFile.text();
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
            notesFile.setText(notesEdit.text);
        }
    }

    function loadNotes() {
        // Déclenche un (re)chargement du fichier si le contenu n'a pas encore été hydraté.
        if (!root.notesLoaded) {
            notesFile.reload();
            if (notesFile.loaded) {
                notesEdit.text = notesFile.text();
                root.notesLoaded = true;
            }
        }
    }

    // ==========================================
    // EN-TÊTE DU BLOC-NOTES (Titre, Copier, Effacer)
    // ==========================================
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

    // ==========================================
    // ZONE D'ÉDITION DU BLOC-NOTES
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        height: 130
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
            contentHeight: Math.max(height, notesEdit.contentHeight)
            interactive: notesEdit.contentHeight > height
            clip: true

            TextEdit {
                id: notesEdit
                width: notesFlickable.width
                height: Math.max(notesFlickable.height, contentHeight)
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
