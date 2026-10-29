pragma Singleton
import QtQuick
import "../theme"
import "../notifications"

QtObject {
    readonly property color background: "#f511171d"
    readonly property color accent: NotificationStyle.accent
    readonly property color accentText: NotificationStyle.accentText
    readonly property color hoverSurface: NotificationStyle.hoverSurface
    readonly property color activeSurface: NotificationStyle.activeSurface
    readonly property color activeBorder: NotificationStyle.activeBorder
    readonly property color border: "#15ffffff"
    readonly property color warning: "#bd9b7e"
    readonly property color destructive: "#c69292"
    readonly property color success: "#91aa9c"
    readonly property string fontFamily: NotificationStyle.fontFamily
    readonly property int radius: 7
    readonly property int taskSpacing: 6
    function metricWidth(width) { return Math.max(72, Math.round(width * Theme.moduleWidthPercentMetrics)); }
    function networkWidth(width) { return Math.max(90, Math.round(width * Theme.moduleWidthPercentNetwork)); }
    function musicWidth(width) {
        var extra = 2 * (metricWidth(width) - Math.round(width * Theme.moduleWidthPercentMetrics))
            + networkWidth(width) - Math.round(width * Theme.moduleWidthPercentNetwork);
        return Math.max(48, Math.round(width * Theme.moduleWidthPercentMpris) - extra);
    }
}
