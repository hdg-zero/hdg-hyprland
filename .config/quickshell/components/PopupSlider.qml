import QtQuick
import QtQuick.Controls

Slider {
    id: root
    property color fillColor: PopupStyle.accent
    from: 0
    to: 100
    stepSize: 1
    implicitHeight: 32
    leftPadding: 6
    rightPadding: 6
    wheelEnabled: true
    focusPolicy: Qt.StrongFocus
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 8
        radius: height / 2
        color: "#12ffffff"
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: root.fillColor
        }
    }
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: 6
        color: PopupStyle.handle
        border.width: root.activeFocus ? 2 : 0
        border.color: root.fillColor
    }
}
