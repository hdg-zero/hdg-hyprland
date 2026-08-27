import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property color iconColor: active ? Theme.accent : Theme.textSecondary
    property color textColor: active ? Theme.textPrimary : Theme.textSecondary
    property color baseColor: "transparent"
    property color hoverColor: Theme.cardBackgroundHover
    property color activeColor: Theme.cardBackground
    property bool active: false
    property real customRadius: Theme.radiusPill
    property int customPaddingH: Theme.spacingMd
    property int customPaddingV: Theme.spacingSm

    signal clicked()
    signal rightClicked()

    implicitWidth: layout.implicitWidth + (customPaddingH * 2)
    implicitHeight: layout.implicitHeight + (customPaddingV * 2)

    radius: customRadius
    color: mouseArea.pressed ? activeColor : (mouseArea.containsMouse ? hoverColor : baseColor)
    border.color: mouseArea.containsMouse ? Theme.glassBorder : "transparent"
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Theme.spacingSm

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            color: mouseArea.containsMouse ? Theme.accent : root.iconColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }
        }

        Text {
            visible: root.text !== ""
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeRegular
            font.bold: root.active
            color: mouseArea.containsMouse ? Theme.textPrimary : root.textColor
            verticalAlignment: Text.AlignVCenter

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            }
        }
    }
}
