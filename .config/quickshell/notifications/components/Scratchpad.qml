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

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingXs

        Text {
            font.family: NotificationStyle.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textSecondary
            text: "Bloc-notes"
        }
        Item { Layout.fillWidth: true }
        PanelIconButton {
            implicitWidth: 28
            implicitHeight: 28
            glyph: "󰆏"
            description: "Copier les notes"
            onClicked: Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "--", notesEdit.text])
        }
        PanelIconButton {
            implicitWidth: 28
            implicitHeight: 28
            glyph: "󰃢"
            description: "Effacer les notes"
            onClicked: {
                notesEdit.text = "";
                NotificationService.flushNotes("");
                root.focusEditor();
            }
        }
    }

    // ==========================================
    // ZONE D'ÉDITION DU BLOC-NOTES
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.relHeight(Theme.scratchpadHeightRatio, root.targetScreen)
        Layout.minimumHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
        radius: Theme.radiusMedium
        color: NotificationStyle.surface
        border.color: notesEdit.activeFocus ? NotificationStyle.activeBorder : NotificationStyle.border
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
                selectionColor: NotificationStyle.accent
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
