import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../theme"

RowLayout {
    id: root

    spacing: Theme.spacingXs
    visible: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0

    function isNetworkItem(item) {
        if (!item) return false;
        var id = (item.id || "").toLowerCase();
        var title = (item.title || "").toLowerCase();
        return id.indexOf("nm-applet") !== -1 || id.indexOf("network") !== -1 || title.indexOf("network") !== -1 || title.indexOf("nm-applet") !== -1;
    }

    Repeater {
        model: SystemTray.items ? SystemTray.items.values : []

        delegate: Rectangle {
            id: trayItem
            required property var modelData

            readonly property var item: modelData
            readonly property bool isNet: root.isNetworkItem(item)

            visible: !isNet
            implicitWidth: isNet ? 0 : Theme.spacingLg * 1.8
            implicitHeight: isNet ? 0 : Theme.spacingLg * 1.8
            radius: Theme.radiusSmall
            color: trayMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"
            border.color: trayMouse.containsMouse ? Theme.glassBorder : "transparent"
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }

            IconImage {
                anchors.centerIn: parent
                width: Theme.spacingLg * 1.375
                height: Theme.spacingLg * 1.375
                source: trayItem.item ? trayItem.item.icon : ""
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function(mouse) {
                    if (!trayItem.item) return;
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.item.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        trayItem.item.secondaryActivate();
                    }
                }

                onWheel: function(wheel) {
                    if (trayItem.item) {
                        trayItem.item.scroll(wheel.angleDelta.y, false);
                    }
                }
            }
        }
    }
}
