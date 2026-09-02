import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"

Rectangle {
    id: root

    implicitHeight: 22
    implicitWidth: wsRow.implicitWidth + Theme.spacingXs * 2
    radius: Theme.radiusSmall
    color: Qt.rgba(1, 1, 1, 0.04)
    border.color: Theme.glassBorderSubtle
    border.width: 1

    // Changement d'espace de travail résilient : activation d'objet Quickshell native
    // et dispatch Hyprland socket / hyprctl garantissant le basculement même lors du défilement molette.
    function changeWorkspace(target) {
        var str = target.toString();
        if (typeof target === "number") {
            var ws = Hyprland.workspaces ? Hyprland.workspaces.values.find(function(w) { return w.id === target; }) : null;
            if (ws && typeof ws.activate === "function") {
                ws.activate();
            }
        }
        Hyprland.dispatch("workspace " + str);
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", str]);
    }

    function handleWheel(wheel) {
        var dy = (wheel && wheel.angleDelta && wheel.angleDelta.y !== 0)
            ? wheel.angleDelta.y
            : ((wheel && wheel.pixelDelta && wheel.pixelDelta.y !== 0) ? wheel.pixelDelta.y : 0);

        if (dy === 0) return;

        // Calcul dynamique de l'espace cible à partir du workspace actuellement actif
        var currentId = (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id) ? Hyprland.focusedWorkspace.id : 1;
        var targetId = dy > 0 ? Math.max(1, currentId - 1) : (currentId + 1);

        changeWorkspace(targetId);

        if (wheel && wheel.accepted !== undefined) {
            wheel.accepted = true;
        }
    }

    // Gestion globale de la molette et du clic sur TOUTE la zone du module Workspaces
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onWheel: function(wheel) {
            root.handleWheel(wheel);
        }
    }

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

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: Theme.spacingXs

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
                implicitHeight: 18
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
                        root.changeWorkspace(wsId);
                    }

                    onWheel: function(wheel) {
                        root.handleWheel(wheel);
                    }
                }
            }
        }
    }
}
