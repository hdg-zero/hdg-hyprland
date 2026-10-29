import QtQuick

Rectangle {
    property real progress: 0
    property color fillColor: PopupStyle.accent
    implicitHeight: 8
    radius: height / 2
    color: "#12ffffff"
    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, parent.progress))
        height: parent.height
        radius: parent.radius
        color: parent.fillColor
    }
}
