import QtQuick
import "../theme"

Rectangle {
    id: root

    property color customColor: Theme.cardBackground
    property color customBorderColor: Theme.glassBorderSubtle
    property real customRadius: Theme.radiusLarge

    color: customColor
    radius: customRadius
    border.color: customBorderColor
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
    }
}
