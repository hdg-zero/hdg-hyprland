import QtQuick
import QtQuick.Controls
import "../../theme"
import "../"

Button {
    id: root

    property string glyph: ""
    property string description: ""
    property bool selected: false
    property bool tile: false
    property bool destructive: false

    implicitWidth: 32
    implicitHeight: tile ? 64 : 32
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: description
    ToolTip.visible: hovered && description !== ""
    ToolTip.text: description
    ToolTip.delay: 600

    contentItem: Text {
        text: root.glyph
        font.family: Theme.fontFamily
        font.pixelSize: root.tile ? 24 : 17
        color: !root.enabled ? Theme.textDisabled
            : root.destructive ? Theme.destructive
            : root.selected ? NotificationStyle.accentText : Theme.textSecondary
        opacity: root.enabled ? 1 : 0.4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: root.tile ? Theme.radiusLarge : Theme.radiusMedium
        color: root.down || root.hovered ? NotificationStyle.hoverSurface
            : root.selected ? NotificationStyle.activeSurface
            : root.tile ? NotificationStyle.surface : "transparent"
        border.width: 1
        border.color: root.activeFocus ? NotificationStyle.accent
            : root.selected ? NotificationStyle.activeBorder
            : root.tile ? NotificationStyle.border : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }
    }
}
