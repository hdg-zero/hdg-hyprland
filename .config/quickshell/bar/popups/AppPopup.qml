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

    cardWidth: 220
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
                width: 20
                height: 20
                source: root.iconSource
                sourceSize: Qt.size(48, 48)
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
                height: 16
                width: wsLabel.implicitWidth + 8
                radius: 4
                color: Qt.rgba(0.365, 0.678, 0.886, 0.15)

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    color: Theme.accent
                    text: "WS " + root.workspaceName
                }
            }
        }

        // Titre de la fenêtre (1 ligne nette)
        Text {
            Layout.fillWidth: true
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.textSecondary
            text: root.winTitle
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // Actions compactes (Basculer & Fermer)
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            // Bouton Basculer
            Rectangle {
                Layout.fillWidth: true
                height: 24
                radius: Theme.radiusSmall
                color: focusMouse.containsMouse ? Theme.accentHover : Qt.rgba(0.365, 0.678, 0.886, 0.2)
                border.color: Theme.accent
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textPrimary
                    text: "󰘳 Basculer"
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

            // Bouton Fermer
            Rectangle {
                width: 55
                height: 24
                radius: Theme.radiusSmall
                color: closeBtnMouse.containsMouse ? Qt.rgba(0.906, 0.298, 0.235, 0.3) : Qt.rgba(1, 1, 1, 0.05)
                border.color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.glassBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                    text: "󰅖 Fermer"
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
