import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../theme"

RowLayout {
    id: root

    spacing: Theme.spacingXs

    function isNetworkItem(item) {
        if (!item) return false;
        var id = (item.id || "").toLowerCase();
        var title = (item.title || "").toLowerCase();
        return id.indexOf("nm-applet") !== -1 || id.indexOf("network") !== -1 || title.indexOf("network") !== -1 || title.indexOf("nm-applet") !== -1;
    }

    readonly property var validTrayItems: {
        if (!SystemTray.items || !SystemTray.items.values) return [];
        return SystemTray.items.values.filter(function(item) {
            return item && !root.isNetworkItem(item);
        });
    }

    visible: validTrayItems.length > 0

    Repeater {
        model: root.validTrayItems

        delegate: Rectangle {
            id: trayItem
            required property var modelData

            readonly property var item: modelData

            implicitWidth: 20
            implicitHeight: 20
            radius: Theme.radiusSmall
            color: trayMouse.containsMouse ? Theme.cardBackgroundHover : "transparent"
            border.color: trayMouse.containsMouse ? Theme.glassBorder : "transparent"
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: (trayItem.item && trayItem.item.icon) ? trayItem.item.icon : ""
                visible: source !== ""
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
