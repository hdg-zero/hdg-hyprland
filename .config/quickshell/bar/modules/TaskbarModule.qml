import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../../theme"
import "../../components"
import "../popups"

RowLayout {
    id: root

    property var parentWindow: null

    spacing: Theme.spacingSm + 2
    visible: Hyprland.toplevels && Hyprland.toplevels.values && Hyprland.toplevels.values.length > 0

    Repeater {
        model: Hyprland.toplevels ? Hyprland.toplevels.values : []

        delegate: Rectangle {
            id: taskItem
            required property var modelData

            readonly property var toplevel: modelData
            readonly property bool isFocused: toplevel ? toplevel.activated : false
            readonly property bool isHovered: taskMouse.containsMouse

            signal entered()
            signal exited()

            readonly property string appClass: {
                if (!toplevel) return "";
                if (toplevel.lastIpcObject && toplevel.lastIpcObject.class) {
                    return toplevel.lastIpcObject.class;
                }
                if (toplevel.lastIpcObject && toplevel.lastIpcObject.initialClass) {
                    return toplevel.lastIpcObject.initialClass;
                }
                if (toplevel.wayland && toplevel.wayland.appId) {
                    return toplevel.wayland.appId;
                }
                return "";
            }

            readonly property var desktopEntry: appClass ? DesktopEntries.heuristicLookup(appClass) : null

            readonly property string iconSource: {
                if (desktopEntry && desktopEntry.icon) {
                    var p1 = Quickshell.iconPath(desktopEntry.icon, true);
                    if (p1 && p1.length > 0) return p1;
                }
                if (appClass && appClass.length > 0) {
                    var c = appClass.trim();
                    var p2 = Quickshell.iconPath(c.toLowerCase(), true);
                    if (p2 && p2.length > 0) return p2;

                    var p3 = Quickshell.iconPath(c, true);
                    if (p3 && p3.length > 0) return p3;

                    var dashed = c.toLowerCase().replace(/\s+/g, "-");
                    var p4 = Quickshell.iconPath(dashed, true);
                    if (p4 && p4.length > 0) return p4;

                    // Résolution sans préfixe reverse-DNS (ex: org.gnome.Nautilus -> nautilus)
                    var dotParts = c.split(".");
                    if (dotParts.length > 1) {
                        var lastPart = dotParts[dotParts.length - 1].toLowerCase();
                        var p5 = Quickshell.iconPath(lastPart, true);
                        if (p5 && p5.length > 0) return p5;
                    }

                    // Alias et fallbacks d'icônes connus
                    var lower = c.toLowerCase();
                    if (lower.indexOf("codium") !== -1 || lower.indexOf("vsc") !== -1) {
                        var pCodium = Quickshell.iconPath("vscodium", true) || Quickshell.iconPath("codium", true) || Quickshell.iconPath("code", true);
                        if (pCodium) return pCodium;
                    }
                    if (lower.indexOf("nautilus") !== -1) {
                        var pNautilus = Quickshell.iconPath("org.gnome.Nautilus", true) || Quickshell.iconPath("nautilus", true) || Quickshell.iconPath("system-file-manager", true);
                        if (pNautilus) return pNautilus;
                    }
                    if (lower.indexOf("mullvad") !== -1 && lower.indexOf("browser") !== -1) {
                        var pMullvad = Quickshell.iconPath("mullvad-browser", true);
                        if (pMullvad) return pMullvad;
                    }
                    if (lower.indexOf("bitwarden") !== -1) {
                        var pBitwarden = Quickshell.iconPath("bitwarden", true);
                        if (pBitwarden) return pBitwarden;
                    }
                }
                return "";
            }

            // Ignorer les applications invisibles ou sans classe
            visible: appClass !== ""

            implicitWidth: 26
            implicitHeight: 22
            radius: Theme.radiusSmall

            color: isFocused ? Qt.rgba(0.365, 0.678, 0.886, 0.25) : (taskMouse.containsMouse ? Theme.cardBackgroundHover : "transparent")
            border.color: isFocused ? Theme.accent : (taskMouse.containsMouse ? Theme.glassBorder : "transparent")
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }
            Behavior on border.color {
                ColorAnimation { duration: Theme.animDurationFast; easing.type: Theme.easingType }
            }

            // Popup paresseuse par tâche : instanciée à l'entrée du curseur sur l'icône,
            // détruite dès l'animation de fermeture terminée (une seule à la fois en pratique).
            LazyPopup {
                id: appLazy
                targetWindow: root.parentWindow
                anchor: taskItem
                popupComponent: Component {
                    AppPopup {
                        parentWindow: root.parentWindow
                        anchorItem: taskItem
                        toplevel: taskItem.toplevel
                        appClass: taskItem.appClass
                        iconSource: taskItem.iconSource
                    }
                }
            }

            // Rendu natif et thread-safe d'icônes Quickshell IconImage
            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 20
                height: 20
                source: taskItem.iconSource
                visible: taskItem.iconSource !== "" && status === Image.Ready
            }

            // Fallback texte si l'icône n'est pas trouvable
            Text {
                anchors.centerIn: parent
                visible: !appIcon.visible
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: isFocused ? Theme.accent : Theme.textPrimary
                text: {
                    var cls = taskItem.appClass.toLowerCase();
                    if (cls.indexOf("kitty") !== -1 || cls.indexOf("terminal") !== -1) return "󰆍";
                    if (cls.indexOf("zen") !== -1 || cls.indexOf("firefox") !== -1 || cls.indexOf("chrome") !== -1 || cls.indexOf("browser") !== -1) return "󰖟";
                    if (cls.indexOf("code") !== -1 || cls.indexOf("codium") !== -1 || cls.indexOf("cursor") !== -1 || cls.indexOf("vsc") !== -1) return "󰨞";
                    if (cls.indexOf("nautilus") !== -1 || cls.indexOf("thunar") !== -1 || cls.indexOf("file") !== -1) return "󰉋";
                    if (cls.indexOf("spotify") !== -1 || cls.indexOf("feishin") !== -1) return "󰓇";
                    if (cls.indexOf("discord") !== -1 || cls.indexOf("vesktop") !== -1) return "󰙯";
                    if (cls.indexOf("mullvad") !== -1 || cls.indexOf("vpn") !== -1) return "󰒄";
                    if (cls.indexOf("slack") !== -1) return "󰒱";
                    return "󰣆";
                }
            }

            MouseArea {
                id: taskMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                onEntered: {
                    taskItem.entered();
                }

                onExited: {
                    taskItem.exited();
                }

                onClicked: function(mouse) {
                    if (!taskItem.toplevel) return;

                    var addr = taskItem.toplevel.address || "";
                    if (addr && addr.indexOf("0x") !== 0) {
                        addr = "0x" + addr;
                    }

                    if (mouse.button === Qt.LeftButton) {
                        // 1. Activation native Wayland via wlr-foreign-toplevel
                        if (taskItem.toplevel.wayland) {
                            taskItem.toplevel.wayland.activate();
                        }
                        // 2. Focus explicite hyprctl
                        if (addr) {
                            Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + addr]);
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        // 1. Fermeture native Wayland
                        if (taskItem.toplevel.wayland) {
                            taskItem.toplevel.wayland.close();
                        }
                        // 2. Fermeture explicite hyprctl
                        if (addr) {
                            Quickshell.execDetached(["hyprctl", "dispatch", "closewindow", "address:" + addr]);
                        }
                    }
                }
            }
        }
    }
}
