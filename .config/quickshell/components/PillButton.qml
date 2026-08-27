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
    property int customPaddingH: Theme.spacingSm
    property int customPaddingV: Theme.spacingXs
    
    property var parentWindow: null
    property real widthPercent: 0
    property real customWidth: 0

    readonly property bool isHovered: mouseArea.containsMouse

    readonly property real effectiveWidth: {
        if (widthPercent > 0) {
            var screenW = (parentWindow && parentWindow.width > 0) 
                ? parentWindow.width 
                : ((parentWindow && parentWindow.screen && parentWindow.screen.width > 0) 
                    ? parentWindow.screen.width 
                    : (Screen.width > 0 ? Screen.width : 1920));
            return Math.round(screenW * widthPercent);
        }
        if (customWidth > 0) return customWidth;
        return layout.implicitWidth + (customPaddingH * 2);
    }

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(var wheel)
    signal entered()
    signal exited()

    implicitWidth: effectiveWidth
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
        width: (root.widthPercent > 0 || root.customWidth > 0) ? Math.max(0, root.effectiveWidth - (root.customPaddingH * 2)) : implicitWidth
        spacing: Theme.spacingXs

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
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
            font.pixelSize: Theme.fontSizeSmall
            font.bold: root.active
            color: mouseArea.containsMouse ? Theme.textPrimary : root.textColor
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: root.widthPercent > 0 || root.customWidth > 0
            elide: Text.ElideRight

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
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onEntered: {
            root.entered();
        }

        onExited: {
            root.exited();
        }

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else if (mouse.button === Qt.MiddleButton) {
                root.middleClicked();
            }
        }

        onWheel: function(wheel) {
            var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : (wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : 0);
            root.scrolled({ angleDelta: { y: dy, x: wheel.angleDelta.x }, pixelDelta: wheel.pixelDelta, delta: dy });
        }
    }
}
