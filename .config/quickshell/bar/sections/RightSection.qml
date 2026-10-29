import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../modules"

RowLayout {
    id: root

    property var parentWindow: null
    property real taskbarMaximumWidth: Infinity
    readonly property real fixedWidth: {
        var items = [tray, clipboard, caffeine, backlight, volume, battery, notifications, clock, power];
        var visibleItems = items.filter(function(item) { return item.visible; });
        return visibleItems.reduce(function(sum, item) { return sum + item.implicitWidth; }, 0)
            + Math.max(0, visibleItems.length - (tasks.visible ? 0 : 1)) * spacing;
    }

    spacing: Theme.spacingXs

    TaskbarModule { id: tasks; parentWindow: root.parentWindow; maximumWidth: root.taskbarMaximumWidth }
    SystemTrayModule { id: tray; parentWindow: root.parentWindow }
    ClipboardModule { id: clipboard; parentWindow: root.parentWindow }
    CaffeineModule { id: caffeine; parentWindow: root.parentWindow }
    BacklightModule { id: backlight; parentWindow: root.parentWindow }
    VolumeModule { id: volume; parentWindow: root.parentWindow }
    BatteryModule { id: battery; parentWindow: root.parentWindow }
    NotificationButton { id: notifications }
    ClockModule { id: clock; parentWindow: root.parentWindow }
    PowerButton { id: power; parentWindow: root.parentWindow }
}
