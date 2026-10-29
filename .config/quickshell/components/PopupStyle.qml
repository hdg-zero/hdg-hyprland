pragma Singleton
import QtQuick
import "../notifications"

QtObject {
    readonly property color accent: NotificationStyle.accent
    readonly property color accentText: NotificationStyle.accentText
    readonly property color activeSurface: NotificationStyle.activeSurface
    readonly property color activeBorder: NotificationStyle.activeBorder
    readonly property color surface: NotificationStyle.surface
    readonly property color hoverSurface: NotificationStyle.hoverSurface
    readonly property color border: "#15ffffff"
    readonly property color handle: NotificationStyle.handle
    readonly property color warning: "#bd9b7e"
    readonly property color destructive: "#c69292"
    readonly property string fontFamily: NotificationStyle.fontFamily
    readonly property int padding: 16
    readonly property int radius: 18
    readonly property int metricWidth: 300
    readonly property int metricHeight: 150
}
