import QtQuick
import "../modules"

Item {
    id: root

    property var parentWindow: null
    property real maximumWidth: 350

    implicitWidth: activeWin.implicitWidth
    implicitHeight: activeWin.implicitHeight

    ActiveWindow {
        id: activeWin
        maximumWidth: root.maximumWidth
        anchors.centerIn: parent
    }
}
