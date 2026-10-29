import QtQuick
import ".."
import "../../theme"
import "../../components"

PillButton {
    id: root
    property string description: ""
    readonly property real screenWidth: parentWindow && parentWindow.width > 0 ? parentWindow.width : Screen.width > 0 ? Screen.width : 1920
    labelFontFamily: BarStyle.fontFamily
    customRadius: BarStyle.radius
    implicitHeight: 22
    iconColor: active ? BarStyle.accentText : Theme.textSecondary
    hoverIconColor: iconColor
    hoverColor: BarStyle.hoverSurface
    activeColor: BarStyle.activeSurface
    baseColor: active ? BarStyle.activeSurface : "transparent"
    idleBorderColor: active ? BarStyle.activeBorder : "transparent"
    hoverBorderColor: BarStyle.border
    Accessible.name: description || text
}
