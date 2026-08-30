import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: root

    property string icon: ""
    property string text: ""
    property color iconColor: Theme.accent
    property color textColor: Theme.textPrimary
    property int iconSize: Theme.fontSizeLarge
    property int textSize: Theme.fontSizeRegular
    property bool textBold: false
    property int customSpacing: Theme.spacingSm

    spacing: customSpacing

    Text {
        id: iconText
        visible: root.icon !== ""
        text: root.icon
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize
        color: root.iconColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        Behavior on color {
            ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
        }
    }

    Text {
        id: labelText
        visible: root.text !== ""
        text: root.text
        font.family: Theme.fontFamily
        font.pixelSize: root.textSize
        font.bold: root.textBold
        color: root.textColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
        }
    }
}
