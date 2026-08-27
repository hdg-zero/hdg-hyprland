import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../theme"

RowLayout {
    id: root

    readonly property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    visible: windowTitle.length > 0
    spacing: Theme.spacingSm

    Text {
        id: titleText
        text: root.windowTitle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeRegular
        font.bold: false
        color: Theme.textSecondary
        elide: Text.ElideRight
        Layout.maximumWidth: 350

        Behavior on color {
            ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
        }
    }
}
