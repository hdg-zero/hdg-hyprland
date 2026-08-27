import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property var toplevel: null
    property string appClass: ""
    property string iconSource: ""

    readonly property string winTitle: {
        if (!toplevel) return "";
        if (toplevel.title) return toplevel.title;
        if (toplevel.wayland && toplevel.wayland.title) return toplevel.wayland.title;
        if (toplevel.lastIpcObject && toplevel.lastIpcObject.title) return toplevel.lastIpcObject.title;
        return appClass || "Application";
    }

    readonly property string appName: {
        if (appClass) {
            var de = DesktopEntries.heuristicLookup(appClass);
            if (de && de.name) return de.name;
            return appClass.charAt(0).toUpperCase() + appClass.slice(1);
        }
        return "Application";
    }

    readonly property string workspaceName: {
        if (!toplevel) return "";
        if (toplevel.workspace && toplevel.workspace.name) return toplevel.workspace.name;
        if (toplevel.workspace && toplevel.workspace.id !== undefined) return "" + toplevel.workspace.id;
        if (toplevel.lastIpcObject && toplevel.lastIpcObject.workspace) {
            return "" + (toplevel.lastIpcObject.workspace.name || toplevel.lastIpcObject.workspace.id || "");
        }
        return "";
    }

    widthPercent: Theme.popupWidthPercentStandard
    cardHeight: contentLayout.implicitHeight + (Theme.spacingMd * 2)

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Theme.spacingSm

        // Header : Icône + Nom App + Badge Workspace
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Image {
                id: popupIcon
                width: Theme.spacingLg * 1.3
                height: Theme.spacingLg * 1.3
                source: root.iconSource
                sourceSize: Qt.size(Theme.spacingXl * 2, Theme.spacingXl * 2)
                smooth: true
                mipmap: true
                visible: root.iconSource !== "" && status === Image.Ready
                fillMode: Image.PreserveAspectFit
            }

            Text {
                visible: !popupIcon.visible
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.accent
                text: "󰣆"
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.appName
                elide: Text.ElideRight
            }

            // Badge Workspace
            Rectangle {
                visible: root.workspaceName !== ""
                height: Theme.spacingLg
                width: wsLabel.implicitWidth + Theme.spacingSm
                radius: Theme.radiusSmall / 2
                color: Qt.rgba(0.365, 0.678, 0.886, 0.15)

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    font.bold: true
                    color: Theme.accent
                    text: "WS " + root.workspaceName
                }
            }
        }

        // Titre de la fenêtre
        Text {
            Layout.fillWidth: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
            text: root.winTitle
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // Boutons d'actions compacts (Uniquement les icônes)
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Bouton Basculer (Icône 󰘳)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: focusMouse.containsMouse ? Theme.accentHover : Qt.rgba(0.365, 0.678, 0.886, 0.2)
                border.color: Theme.accent
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    color: Theme.textPrimary
                    text: "󰘳"
                }

                MouseArea {
                    id: focusMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.toplevel) return;
                        var addr = root.toplevel.address || "";
                        if (addr && addr.indexOf("0x") !== 0) addr = "0x" + addr;
                        if (root.toplevel.wayland) root.toplevel.wayland.activate();
                        if (addr) Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + addr]);
                        root.close();
                    }
                }
            }

            // Bouton Fermer (Icône 󰅖)
            Rectangle {
                Layout.fillWidth: true
                height: Theme.spacingLg * 1.6
                radius: Theme.radiusSmall
                color: closeBtnMouse.containsMouse ? Qt.rgba(0.906, 0.298, 0.235, 0.4) : Qt.rgba(1, 1, 1, 0.05)
                border.color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.glassBorder
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                    text: "󰅖"
                }

                MouseArea {
                    id: closeBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.toplevel) return;
                        var addr = root.toplevel.address || "";
                        if (addr && addr.indexOf("0x") !== 0) addr = "0x" + addr;
                        if (root.toplevel.wayland) root.toplevel.wayland.close();
                        if (addr) Quickshell.execDetached(["hyprctl", "dispatch", "closewindow", "address:" + addr]);
                        root.close();
                    }
                }
            }
        }
    }
}
