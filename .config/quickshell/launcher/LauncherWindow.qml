import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import "../theme"
import "../components"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LauncherService.launcherVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Maintient la fenêtre active pendant l'animation de fermeture
    visible: LauncherService.launcherVisible || animProgress > 0.01

    // Progression d'animation d'ouverture/fermeture style Apple
    property real animProgress: LauncherService.launcherVisible ? 1.0 : 0.0
    Behavior on animProgress {
        NumberAnimation {
            duration: LauncherService.launcherVisible ? 220 : 160
            easing.type: LauncherService.launcherVisible ? Easing.OutBack : Easing.InQuad
            easing.overshoot: 1.12
        }
    }

    property string searchQuery: ""
    property int selectedIndex: 0
    property var appHistory: ({})

    // Chargement de l'historique d'utilisation des applications (fréquence MRU)
    Process {
        id: loadHistoryProc
        command: ["sh", "-c", "mkdir -p \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell\" && cat \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/launcher_history.json\" 2>/dev/null || echo '{}'"]
        stdout: StdioCollector { id: histOut }
        onExited: {
            try {
                var json = histOut.text.trim();
                if (json) {
                    root.appHistory = JSON.parse(json);
                }
            } catch (e) {
                root.appHistory = {};
            }
        }
    }

    function saveHistory() {
        var str = JSON.stringify(root.appHistory);
        Quickshell.execDetached(["sh", "-c", "mkdir -p \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell\" && printf '%s' \"$1\" > \"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/launcher_history.json\"", "--", str]);
    }

    // Liste filtrée et triée par fréquence d'utilisation (MRU) et pertinence
    readonly property var filteredApps: {
        if (!DesktopEntries.applications) return [];
        var list = DesktopEntries.applications.values ? DesktopEntries.applications.values : DesktopEntries.applications;
        if (!list) return [];

        var q = root.searchQuery.toLowerCase().trim();
        var res = [];

        for (var i = 0; i < list.length; i++) {
            var app = list[i];
            if (!app) continue;
            var name = (app.name || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            var exec = (app.execString || app.command || "").toLowerCase();
            var id = (app.id || "").toLowerCase();

            if (!q || name.indexOf(q) !== -1 || comment.indexOf(q) !== -1 || exec.indexOf(q) !== -1 || id.indexOf(q) !== -1) {
                res.push(app);
            }
        }

        res.sort(function(a, b) {
            var idA = a.id || a.name || "";
            var idB = b.id || b.name || "";
            var countA = (root.appHistory && root.appHistory[idA]) ? root.appHistory[idA] : 0;
            var countB = (root.appHistory && root.appHistory[idB]) ? root.appHistory[idB] : 0;

            if (q) {
                var nameA = (a.name || "").toLowerCase();
                var nameB = (b.name || "").toLowerCase();
                var startsA = (nameA.indexOf(q) === 0);
                var startsB = (nameB.indexOf(q) === 0);
                if (startsA && !startsB) return -1;
                if (!startsA && startsB) return 1;

                // À pertinence égale, trier par fréquence d'utilisation
                if (countA !== countB) return countB - countA;
                return nameA.localeCompare(nameB);
            }

            // Vue par défaut sans recherche : trier strictement par fréquence d'utilisation décroissante
            if (countA !== countB) return countB - countA;
            return (a.name || "").localeCompare(b.name || "");
        });

        return res;
    }

    function launchApp(app) {
        if (!app) return;

        // Incrémentation du compteur de fréquence
        var appId = app.id || app.name || "";
        if (appId) {
            var updated = Object.assign({}, root.appHistory);
            updated[appId] = (updated[appId] || 0) + 1;
            root.appHistory = updated;
            saveHistory();
        }

        LauncherService.close();

        if (typeof app.execute === "function") {
            app.execute();
        } else if (app.command) {
            Quickshell.execDetached(["uwsm", "app", "--"].concat(app.command));
        } else if (app.execString) {
            Quickshell.execDetached(["sh", "-c", "uwsm app -- " + app.execString]);
        }
    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            launchApp(filteredApps[selectedIndex]);
        }
    }

    onVisibleChanged: {
        if (visible && LauncherService.launcherVisible) {
            root.searchQuery = "";
            root.selectedIndex = 0;
            searchInput.text = "";
            searchInput.forceActiveFocus();
            if (!loadHistoryProc.running) {
                loadHistoryProc.running = true;
            }
        }
    }

    // Fond assombri avec fondu fluide
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.03, 0.05, 0.70)
        opacity: root.animProgress

        MouseArea {
            anchors.fill: parent
            onClicked: LauncherService.close()
        }
    }

    // Carte centrale Glassmorphic Obsidian Glass & Glacier Blue (33% largeur écran)
    Rectangle {
        id: dialogCard
        anchors.centerIn: parent
        width: Math.max(480, Math.round(Theme.relWidth(0.33, root.screen)))
        implicitHeight: dialogLayout.implicitHeight + Theme.spacingLg * 2
        radius: Theme.radiusXLarge
        color: Qt.rgba(0.043, 0.059, 0.078, 0.85) // Obsidian Glass
        border.color: Theme.glassBorder           // Glacier Blue border
        border.width: 1
        clip: true

        // Animation d'ouverture et fermeture style Apple (Spotlight / Springboard)
        scale: 0.92 + (0.08 * root.animProgress)
        opacity: Math.min(1.0, root.animProgress * 1.25)
        transformOrigin: Item.Center

        // Événements clavier globaux
        Keys.onEscapePressed: function(event) {
            LauncherService.close();
            event.accepted = true;
        }

        Keys.onReturnPressed: function(event) {
            launchSelected();
            event.accepted = true;
        }

        Keys.onEnterPressed: function(event) {
            launchSelected();
            event.accepted = true;
        }

        Keys.onLeftPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = Math.max(0, root.selectedIndex - 1);
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        Keys.onRightPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = Math.min(filteredApps.length - 1, root.selectedIndex + 1);
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        Keys.onUpPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = Math.max(0, root.selectedIndex - 5);
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        Keys.onDownPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = Math.min(filteredApps.length - 1, root.selectedIndex + 5);
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        Keys.onTabPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = (root.selectedIndex + 1) % filteredApps.length;
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        Keys.onBacktabPressed: function(event) {
            if (filteredApps.length > 0) {
                root.selectedIndex = (root.selectedIndex - 1 + filteredApps.length) % filteredApps.length;
                appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
            }
            event.accepted = true;
        }

        ColumnLayout {
            id: dialogLayout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacingLg
            }
            spacing: Theme.spacingLg

            // ==========================================
            // 1. BARRE DE RECHERCHE (Faint Glass & Loupe Glacier Blue)
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                height: 46
                radius: Theme.radiusMedium
                color: Qt.rgba(1.0, 1.0, 1.0, 0.06)
                border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: Theme.spacingMd
                        rightMargin: Theme.spacingMd
                    }
                    spacing: Theme.spacingSm

                    // Icône de recherche Glacier Blue
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.accent
                        text: "󰍉"
                    }

                    // Champ de saisie texte
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.textPrimary
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.backgroundSolid
                        selectByMouse: true
                        activeFocusOnPress: true

                        Text {
                            anchors.fill: parent
                            visible: !searchInput.text && !searchInput.activeFocus
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.textDisabled
                            text: "Rechercher une application..."
                        }

                        onTextChanged: {
                            root.searchQuery = text;
                            root.selectedIndex = 0;
                        }
                    }

                    // Bouton effacer la recherche
                    Rectangle {
                        visible: searchInput.text !== ""
                        width: 22
                        height: 22
                        radius: width / 2
                        color: clearSearchMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.textSecondary
                            text: "󰅖"
                        }

                        MouseArea {
                            id: clearSearchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = "";
                                searchInput.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            // ==========================================
            // 2. GRILLE D'APPLICATIONS (5 COLONNES, HAUTEUR ACCRUE & CENTRAGE DYNAMIQUE)
            // ==========================================
            Item {
                id: gridContainer
                Layout.fillWidth: true
                implicitHeight: Math.min(Math.round(Theme.relHeight(0.55, root.screen)), Math.max(135, Math.ceil(Math.min(10, root.filteredApps.length) / 5.0) * 135))
                clip: true

                // État vide
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    spacing: Theme.spacingXs

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Math.round(Theme.fontSizeTitle * 1.6)
                        color: Theme.textDisabled
                        text: "󰱵"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDisabled
                        text: "Aucune application trouvée"
                    }
                }

                // Grille avec centrage dynamique si moins de 5 éléments
                GridView {
                    id: appGrid
                    visible: root.filteredApps.length > 0
                    model: root.filteredApps

                    readonly property int defaultCellWidth: Math.floor(gridContainer.width / 5)

                    // Centrage dynamique si moins de 5 éléments
                    width: root.filteredApps.length < 5 ? (root.filteredApps.length * defaultCellWidth) : gridContainer.width
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    cellWidth: defaultCellWidth
                    cellHeight: 135
                    clip: true

                    delegate: Item {
                        id: delegateRoot
                        required property var modelData
                        required property int index

                        width: appGrid.cellWidth
                        height: appGrid.cellHeight

                        readonly property bool isSelected: (index === root.selectedIndex)

                        Rectangle {
                            id: appCard
                            anchors {
                                fill: parent
                                margins: 4
                            }
                            radius: Theme.radiusLarge
                            color: (appMouse.containsMouse || isSelected) ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            border.color: isSelected ? Theme.accent : (appMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.16) : "transparent")
                            border.width: isSelected ? 2 : 1
                            scale: (appMouse.containsMouse || isSelected) ? 1.06 : 1.0

                            Behavior on scale { NumberAnimation { duration: Theme.animDurationFast; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: Theme.animDurationFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animDurationFast } }

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: Theme.spacingMd
                                }
                                spacing: Theme.spacingSm

                                Item { Layout.fillHeight: true }

                                // Grande icône 52x52 centrée
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 52
                                    height: 52

                                    IconImage {
                                        anchors.fill: parent
                                        source: {
                                            var iconName = delegateRoot.modelData.icon || delegateRoot.modelData.id || "";
                                            if (!iconName) return "";
                                            if (iconName.indexOf("/") !== -1) return iconName;
                                            var resolved = Quickshell.iconPath(iconName, true);
                                            if (resolved) return resolved;
                                            resolved = Quickshell.iconPath(iconName.toLowerCase(), true);
                                            if (resolved) return resolved;
                                            return "";
                                        }
                                    }

                                    // Icône de secours si introuvable
                                    Text {
                                        anchors.centerIn: parent
                                        visible: parent.children[0].source === ""
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Math.round(Theme.fontSizeTitle * 1.8)
                                        color: isSelected ? Theme.accent : Theme.textSecondary
                                        text: "󰀻"
                                    }
                                }

                                Item { Layout.fillHeight: true }

                                // Nom de l'application centré sous l'icône
                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignHCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: isSelected
                                    color: isSelected ? Theme.textPrimary : Theme.textSecondary
                                    text: delegateRoot.modelData.name || "App"
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedIndex = delegateRoot.index;
                                    root.launchApp(delegateRoot.modelData);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
