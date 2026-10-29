import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

ColumnLayout {
    id: root
    property string label: ""
    property bool expanded: false
    default property alias details: detailContainer.data
    spacing: Theme.spacingSm
    Button {
        id: toggle
        Layout.fillWidth: true
        implicitHeight: 28
        padding: 0
        Accessible.name: root.label + (root.expanded ? ", replier" : ", déplier")
        onClicked: root.expanded = !root.expanded
        contentItem: RowLayout {
            PopupText { Layout.fillWidth: true; text: root.label; font.pixelSize: 11; color: Theme.textSecondary }
            PopupGlyph { text: root.expanded ? "󰅃" : "󰅀"; font.pixelSize: 12; color: Theme.textSecondary }
        }
        background: Rectangle {
            radius: 6
            color: toggle.hovered ? PopupStyle.hoverSurface : "transparent"
            border.width: toggle.activeFocus ? 1 : 0
            border.color: PopupStyle.accent
        }
    }
    ColumnLayout {
        id: detailContainer
        Layout.fillWidth: true
        visible: root.expanded
        spacing: Theme.spacingSm
    }
}
