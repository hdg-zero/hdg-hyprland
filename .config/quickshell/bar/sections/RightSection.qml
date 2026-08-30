import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../modules"

RowLayout {
    id: root

    property var parentWindow: null

    spacing: Theme.spacingXs

    TaskbarModule { parentWindow: root.parentWindow }
    SystemTrayModule {}
    BacklightModule { parentWindow: root.parentWindow }
    VolumeModule { parentWindow: root.parentWindow }
    BatteryModule { parentWindow: root.parentWindow }
    NotificationButton {}
    ClockModule { parentWindow: root.parentWindow }
    PowerButton { parentWindow: root.parentWindow }
}
