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
        return appClass || "Fenêtre d'application";
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

    readonly property bool isFloating: toplevel && toplevel.lastIpcObject ? toplevel.lastIpcObject.floating : false
    readonly property bool isFullscreen: toplevel && toplevel.lastIpcObject ? toplevel.lastIpcObject.fullscreen : false

    cardWidth: 280
    cardHeight: contentLayout.implicitHeight + (Theme.spacingMd * 2)

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Theme.spacingMd

        // Header : Icône + Nom App + Badge Workspace
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Image {
                id: popupIcon
                width: 28
                height: 28
                source: root.iconSource
                sourceSize: Qt.size(64, 64)
                smooth: true
                mipmap: true
                visible: root.iconSource !== "" && status === Image.Ready
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                width: 28
                height: 28
                radius: Theme.radiusSmall
                color: Qt.rgba(1, 1, 1, 0.05)
                visible: !popupIcon.visible

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.accent
                    text: "󰣆"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.appName
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                    text: root.appClass
                    elide: Text.ElideRight
                    visible: root.appClass !== "" && root.appClass !== root.appName
                }
            }

            // Badge Workspace
            Rectangle {
                visible: root.workspaceName !== ""
                height: 20
                width: wsLabel.implicitWidth + 12
                radius: 10
                color: Qt.rgba(0.365, 0.678, 0.886, 0.15)
                border.color: Qt.rgba(0.365, 0.678, 0.886, 0.3)
                border.width: 1

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.accent
                    text: "WS " + root.workspaceName
                }
            }
        }

        // Ligne de séparation
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Titre complet de la fenêtre
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: winTitleText.implicitHeight + (Theme.spacingSm * 2)
            radius: Theme.radiusSmall
            color: Qt.rgba(0, 0, 0, 0.25)
            border.color: Theme.glassBorderSubtle
            border.width: 1

            Text {
                id: winTitleText
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacingSm
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeRegular
                color: Theme.textPrimary
                text: root.winTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }

        // Badges d'état (Flottante, Plein écran)
        RowLayout {
            visible: root.isFloating || root.isFullscreen
            spacing: Theme.spacingSm

            Rectangle {
                visible: root.isFloating
                height: 18
                width: floatLabel.implicitWidth + 10
                radius: 4
                color: Qt.rgba(1, 1, 1, 0.08)

                Text {
                    id: floatLabel
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.textSecondary
                    text: "󰉈 Flottante"
                }
            }

            Rectangle {
                visible: root.isFullscreen
                height: 18
                width: fsLabel.implicitWidth + 10
                radius: 4
                color: Qt.rgba(0.95, 0.77, 0.06, 0.15)

                Text {
                    id: fsLabel
                    anchors.centerIn: parent
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.warning
                    text: "󰊓 Plein écran"
                }
            }
        }

        // Actions rapides (Focus & Fermer)
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            // Bouton Focus
            Rectangle {
                Layout.fillWidth: true
                height: 30
                radius: Theme.radiusSmall
                color: focusMouse.containsMouse ? Theme.accentHover : Qt.rgba(0.365, 0.678, 0.886, 0.2)
                border.color: Theme.accent
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXs

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textPrimary
                        text: "󰘳"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        color: Theme.textPrimary
                        text: "Basculer"
                    }
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
                width: 70
                height: 30
                radius: Theme.radiusSmall
                color: closeBtnMouse.containsMouse ? Qt.rgba(0.906, 0.298, 0.235, 0.3) : Qt.rgba(1, 1, 1, 0.05)
                border.color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.glassBorder
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                        text: "󰅖"
                    }
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: closeBtnMouse.containsMouse ? Theme.destructive : Theme.textSecondary
                        text: "Fermer"
                    }
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
