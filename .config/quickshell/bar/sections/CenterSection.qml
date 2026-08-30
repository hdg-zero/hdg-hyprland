import QtQuick
import "../modules"

Item {
    id: root

    property var parentWindow: null

    implicitWidth: activeWin.implicitWidth
    implicitHeight: activeWin.implicitHeight

    ActiveWindow {
        id: activeWin
        anchors.centerIn: parent
    }
}
