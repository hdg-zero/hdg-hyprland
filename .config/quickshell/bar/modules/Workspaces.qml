import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"

RowLayout {
    id: root

    spacing: Theme.spacingXs

    // Liste dynamique des identifiants d'espaces de travail (1-4 fixes + workspaces actifs supplémentaires)
    property var workspaceIds: {
        var base = [1, 2, 3, 4];
        if (!Hyprland.workspaces) return base;
        
        var values = Hyprland.workspaces.values;
        if (!values) return base;

        for (var i = 0; i < values.length; i++) {
            var id = values[i].id;
            if (id > 0 && base.indexOf(id) === -1) {
                base.push(id);
            }
        }
        base.sort(function(a, b) { return a - b; });
        return base;
    }

    Repeater {
        model: root.workspaceIds

        delegate: Rectangle {
            id: wsButton
            required property int modelData

            readonly property int wsId: modelData
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            // Doc Quickshell.Hyprland/HyprlandWorkspace v0.3.x : pas de propriété « windows » ;
            // les fenêtres du workspace sont exposées par « toplevels » (ObjectModel → .values).
            readonly property var wsObj: Hyprland.workspaces ? Hyprland.workspaces.values.find(function(w) { return w.id === wsId; }) : null
            readonly property bool hasWindows: !!wsObj && !!wsObj.toplevels && wsObj.toplevels.values.length > 0

            implicitWidth: 20
            implicitHeight: 20
            radius: Theme.radiusSmall

            color: isFocused ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : (wsMouse.containsMouse ? Theme.cardBackgroundHover : "transparent")
            border.color: isFocused ? Theme.accent : (wsMouse.containsMouse ? Theme.glassBorder : "transparent")
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }
            Behavior on border.color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }

            Text {
                anchors.centerIn: parent
                text: isFocused ? "" : (hasWindows ? "" : wsId.toString())
                font.family: Theme.fontFamily
                font.pixelSize: isFocused || hasWindows ? Theme.fontSizeSmall : Theme.fontSizeTiny
                font.bold: isFocused
                color: isFocused ? Theme.accent : (hasWindows ? Theme.textPrimary : Theme.textDisabled)

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()]);
                }

                onWheel: function(wheel) {
                    var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : (wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : 0);
                    if (dy > 0) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "e-1"]);
                    } else if (dy < 0) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "e+1"]);
                    }
                }
            }
        }
    }
}
