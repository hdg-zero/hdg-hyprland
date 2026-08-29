import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../modules"

RowLayout {
    id: root

    property var parentWindow: null

    spacing: Theme.spacingXs

    LauncherButton {}
    Workspaces {}
    CpuModule { parentWindow: root.parentWindow }
    MemoryModule { parentWindow: root.parentWindow }
    NetworkModule { parentWindow: root.parentWindow }
    MprisModule { parentWindow: root.parentWindow }
}
