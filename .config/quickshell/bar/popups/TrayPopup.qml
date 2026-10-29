import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../theme"
import "../../components"

// Liste des applis de la zone de notification. Clics identiques à l'ancien tray de la barre :
// gauche = activate(), droit = secondaryActivate(), molette = scroll().
ModulePopup {
    id: root

    property var isTrayItemVisible: function(item) { return !!item; }

    cardWidth: 230
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 2

        // ObjectModel Quickshell passé directement (insertions/suppressions fines), filtrage
        // dans le délégué : pas de tableau recréé à chaque changement (audit §2).
        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: trayItem
                required property var modelData

                readonly property var item: modelData
                readonly property string label: item ? (item.title || item.tooltipTitle || item.id || "Application") : "Application"

                visible: root.isTrayItemVisible(item)
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 8
                color: trayMouse.containsMouse ? PopupStyle.hoverSurface : "transparent"
                Accessible.name: label

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    spacing: Theme.spacingMd

                    IconImage {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        implicitSize: 18
                        source: (trayItem.item && trayItem.item.icon) ? (Quickshell.iconPath(trayItem.item.icon, true) || trayItem.item.icon) : ""
                        visible: source !== ""
                    }

                    PopupText {
                        Layout.fillWidth: true
                        text: trayItem.label
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: function(mouse) {
                        if (!trayItem.item) return;
                        if (mouse.button === Qt.LeftButton) {
                            trayItem.item.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            trayItem.item.secondaryActivate();
                        }
                    }

                    onWheel: function(wheel) {
                        if (trayItem.item) {
                            trayItem.item.scroll(wheel.angleDelta.y, false);
                        }
                    }
                }
            }
        }
    }
}
