import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../"

ColumnLayout {
    id: root

    property var targetScreen: null
    property bool isHydrating: false
    spacing: Theme.spacingSm

    // Synchronisation avec le singleton NotificationService (préservé en mémoire lors
    // des destructions/recréations du Loader dans shell.qml)
    function loadNotes() {
        if (notesEdit.text !== NotificationService.scratchpadText) {
            root.isHydrating = true;
            notesEdit.text = NotificationService.scratchpadText;
            root.isHydrating = false;
        }
    }

    // Activation directe du focus et positionnement du curseur à la fin du texte.
    // Doc Qt Quick TextEdit (https://doc.qt.io/qt-6/qml-qtquick-textedit.html) :
    // forceActiveFocus() prend le focus d'entrée clavier et cursorPosition place le point d'insertion.
    function focusEditor() {
        notesEdit.forceActiveFocus();
        notesEdit.cursorPosition = notesEdit.text.length;
    }

    Component.onCompleted: {
        loadNotes();
        Qt.callLater(focusEditor);
    }

    Component.onDestruction: {
        NotificationService.flushNotes(notesEdit.text);
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
                    NotificationService.flushNotes("");
                }
            }
        }
    }

    // ==========================================
    // ZONE D'ÉDITION DU BLOC-NOTES
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        height: Theme.relHeight(Theme.scratchpadHeightRatio, root.targetScreen)
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
                focus: true
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
                    if (!root.isHydrating && notesEdit.text !== NotificationService.scratchpadText) {
                        NotificationService.updateNotes(notesEdit.text);
                    }
                }
            }
        }
    }
}
