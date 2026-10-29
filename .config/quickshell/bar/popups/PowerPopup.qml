import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../components"
import "../../session"

ModulePopup {
    id: root
    cardWidth: 220
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2
    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Theme.spacingXs
        Repeater {
            model: [
                { label: "Verrouiller", glyph: "󰌾", action: function() { SessionService.lock(); } },
                { label: "Veille", glyph: "󰤄", action: function() { SessionService.suspend(); } },
                { label: "Déconnexion", glyph: "󰍃", action: function() { SessionService.logout(); } },
                { label: "Redémarrer", glyph: "󰜉", action: function() { SessionService.reboot(); } },
                { label: "Éteindre", glyph: "⏻", action: function() { SessionService.shutdown(); } }
            ]
            delegate: Button {
                id: action
                required property var modelData
                required property int index
                Layout.fillWidth: true
                implicitHeight: 34
                padding: 7
                Accessible.name: modelData.label
                onClicked: { root.close(); modelData.action(); }
                contentItem: RowLayout {
                    spacing: Theme.spacingMd
                    PopupGlyph { text: action.modelData.glyph; font.pixelSize: 17; color: action.index === 4 ? PopupStyle.destructive : Theme.textSecondary }
                    PopupText { Layout.fillWidth: true; text: action.modelData.label; font.pixelSize: 12; color: action.index === 4 ? PopupStyle.destructive : Theme.textPrimary }
                }
                background: Rectangle { radius: 8; color: action.hovered ? PopupStyle.hoverSurface : "transparent"; border.width: action.activeFocus ? 1 : 0; border.color: PopupStyle.accent }
            }
        }
    }
}
