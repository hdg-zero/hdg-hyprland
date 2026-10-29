import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../components"

// Explorateur de l'historique cliphist : clic = recopier l'entrée, clic milieu = la supprimer.
ModulePopup {
    id: root

    // Nombre d'entrées affichées (les plus récentes d'abord, ordre de `cliphist list`).
    readonly property int maxEntries: 40
    property var entries: []

    cardWidth: 340
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2

    function refresh() {
        if (!listProc.running) listProc.running = true;
    }

    // Chaque entrée est la ligne brute de `cliphist list` (« id<TAB>aperçu ») : decode et
    // delete la relisent telle quelle sur stdin, passée en argument pour éviter toute injection.
    function copyEntry(line) {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "--", line]);
        root.close();
    }

    function deleteEntry(line) {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "--", line]);
        root.entries = root.entries.filter(function(e) { return e !== line; });
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        root.entries = [];
    }

    onIsOpenChanged: if (isOpen) refresh()
    Component.onCompleted: refresh()

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector { id: listOut }
        onExited: {
            var lines = listOut.text.split("\n").filter(function(l) { return l.indexOf("\t") > 0; });
            root.entries = lines.slice(0, root.maxEntries);
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            PopupText {
                Layout.fillWidth: true
                text: "Presse-papiers"
                font.pixelSize: 13
                font.bold: true
            }
            PopupIconButton {
                glyph: "󰩺"
                description: "Tout effacer"
                enabled: root.entries.length > 0
                onClicked: root.wipe()
            }
        }

        PopupText {
            visible: root.entries.length === 0
            text: "Historique vide"
            font.pixelSize: 12
            opacity: 0.6
        }

        Repeater {
            model: root.entries

            delegate: Rectangle {
                id: entryItem
                required property var modelData

                readonly property string preview: {
                    var tab = modelData.indexOf("\t");
                    return (tab >= 0 ? modelData.slice(tab + 1) : modelData).replace(/\s+/g, " ").trim();
                }
                readonly property bool isImage: preview.indexOf("[[ binary data") === 0

                Layout.fillWidth: true
                implicitHeight: 28
                radius: 8
                color: entryMouse.containsMouse ? PopupStyle.hoverSurface : "transparent"
                Accessible.name: preview

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    spacing: Theme.spacingMd

                    PopupText {
                        text: entryItem.isImage ? "󰋩" : "󰅍"
                        font.pixelSize: 13
                        opacity: 0.7
                    }

                    PopupText {
                        Layout.fillWidth: true
                        text: entryItem.preview
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                MouseArea {
                    id: entryMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.MiddleButton) root.deleteEntry(entryItem.modelData);
                        else root.copyEntry(entryItem.modelData);
                    }
                }
            }
        }

        PopupText {
            visible: root.entries.length > 0
            text: "Clic : recopier · clic milieu : supprimer"
            font.pixelSize: 10
            opacity: 0.5
        }
    }
}
