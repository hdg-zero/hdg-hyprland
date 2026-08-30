import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import "../theme"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    property var targetScreen: null
    screen: targetScreen || modelData

    readonly property bool isCurrentMonitor: {
        if (!root.screen) return true;
        var focused = Hyprland.focusedMonitor;
        var current = Hyprland.monitorFor(root.screen);
        return (focused && current) ? (focused.id === current.id) : true;
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: (LauncherService.launcherVisible && isCurrentMonitor) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-launcher"

    // Maintient la fenêtre active pendant l'animation de fermeture
    visible: LauncherService.launcherVisible || animProgress > 0.01

    // Progression d'animation d'ouverture/fermeture style Apple.
    // Lazy loading : la fenêtre n'existe désormais que quand le service demande l'ouverture
    // (ou pendant les 300 ms de keepalive post-fermeture). Pour que le ressort d'ouverture
    // (Easing.OutBack) se voie à chaque création, la progression démarre à 0 et le binding
    // n'est établi qu'une fois le fenêtre montée (Component.onCompleted) — sinon
    // animProgress s'initialiserait directement à 1 et l'animation d'entrée serait perdue.
    property real animProgress: 0.0
    Component.onCompleted: {
        animProgress = Qt.binding(function() {
            return LauncherService.launcherVisible ? 1.0 : 0.0;
        });
    }
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

    readonly property bool isCommandMode: root.searchQuery.trim().indexOf(">") === 0
    readonly property string commandString: isCommandMode ? root.searchQuery.trim().substring(1).trim() : ""

    // Résolution robuste et exhaustive des icônes d'applications
    property var iconCache: ({})

    function resolveAppIcon(app) {
        if (!app) return "";
        var appId = app.id || app.name || "";
        if (appId && root.iconCache[appId] !== undefined) {
            return root.iconCache[appId];
        }

        var iconName = app.icon || "";
        var appName = (app.name || "").toLowerCase();
        var execStr = (app.execString || app.command || "").toString().toLowerCase();

        // 1. Si chemin absolu direct
        if (iconName.indexOf("/") === 0) {
            if (appId) root.iconCache[appId] = "file://" + iconName;
            return "file://" + iconName;
        }
        if (iconName.indexOf("file://") === 0) {
            if (appId) root.iconCache[appId] = iconName;
            return iconName;
        }

        // 2. Ensemble de termes candidats ordonnés
        var candidates = [];
        if (iconName) {
            candidates.push(iconName);
            candidates.push(iconName.toLowerCase());
            candidates.push(iconName.replace(/\.(png|svg|xpm|ico)$/i, ""));
        }
        if (appId) {
            candidates.push(appId);
            candidates.push(appId.toLowerCase());
            var dotParts = appId.toLowerCase().split(".");
            if (dotParts.length > 1) {
                candidates.push(dotParts[dotParts.length - 1]);
                if (dotParts[1] === "gnome") candidates.push("gnome-" + dotParts[dotParts.length - 1]);
            }
        }
        if (appName) {
            candidates.push(appName);
            candidates.push(appName.replace(/\s+/g, "-"));
        }
        if (execStr) {
            var execBinary = execStr.split(/\s+/)[0].split("/").pop();
            if (execBinary) candidates.push(execBinary);
        }

        // Table de correspondance d'alias enrichie
        var aliasMap = {
            "navigateur mullvad": "mullvad-browser",
            "mullvad": "mullvad-browser",
            "mullvadbrowser": "mullvad-browser",
            "vscodium": "vscodium",
            "codium": "vscodium",
            "code": "visual-studio-code",
            "cursor": "co.anysphere.cursor",
            "agent-ia": "distrobox",
            "distrobox": "distrobox",
            "portal": "applications-system-symbolic",
            "xdg-desktop-portal-gtk": "applications-system-symbolic",
            "user-dirs-update-gtk": "user-home",
            "user folders update": "user-home",
            "lstopo": "hwloc",
            "hardware locality lstopo": "hwloc",
            "avahi zeroconf browser": "network-wired",
            "avahi ssh server browser": "network-wired",
            "avahi vnc server browser": "network-wired",
            "view file": "document-open",
            "access prompt": "security-medium",
            "manage printing": "cups"
        };

        // Expansion des alias en UNE passe bornée : chaque candidat est traité au plus une
        // fois (Set de déduplication). L'ancienne boucle poussait dans le tableau PENDANT son
        // parcours : toute clé auto-référentielle de la table (« vscodium » → « vscodium »,
        // « distrobox » → « distrobox ») provoquait une boucle infinie qui figeait le thread
        // QML à l'ouverture du lanceur jusqu'au crash de Quickshell.
        var seen = {};
        var expanded = [];
        for (var i = 0; i < candidates.length; i++) {
            var c = candidates[i];
            if (!c || seen[c]) continue;
            seen[c] = true;
            expanded.push(c);
            if (aliasMap[c] && !seen[aliasMap[c]]) {
                seen[aliasMap[c]] = true;
                expanded.push(aliasMap[c]);
            }
        }
        candidates = expanded;

        // Recherche via Quickshell et chemins standards
        for (var k = 0; k < candidates.length; k++) {
            var term = candidates[k];
            if (!term) continue;
            if (term.indexOf("/") === 0) return "file://" + term;
            if (term.indexOf("file://") === 0) return term;

            var clean = term.replace(/\.(png|svg|xpm|ico)$/i, "");

            // Résolution Quickshell
            var resolved = Quickshell.iconPath(clean, true);
            if (resolved) {
                if (appId) root.iconCache[appId] = resolved;
                return resolved;
            }
            resolved = Quickshell.iconPath(clean.toLowerCase(), true);
            if (resolved) {
                if (appId) root.iconCache[appId] = resolved;
                return resolved;
            }

            // Formats symboliques Adwaita
            if (clean.indexOf("-symbolic") === -1) {
                resolved = Quickshell.iconPath(clean + "-symbolic", true);
                if (resolved) {
                    if (appId) root.iconCache[appId] = resolved;
                    return resolved;
                }
            }
        }

        if (appId) root.iconCache[appId] = "";
        return "";
    }

    // Icône de secours Nerd Font intelligente selon la catégorie ou le nom
    function getFallbackIcon(app) {
        if (!app) return "󰘔";
        var str = ((app.name || "") + " " + (app.comment || "") + " " + (app.id || "") + " " + (app.execString || "")).toLowerCase();
        if (str.indexOf("browser") !== -1 || str.indexOf("web") !== -1 || str.indexOf("mullvad") !== -1 || str.indexOf("chrome") !== -1 || str.indexOf("navig") !== -1) return "󰈹";
        if (str.indexOf("terminal") !== -1 || str.indexOf("kitty") !== -1 || str.indexOf("foot") !== -1 || str.indexOf("sh") !== -1 || str.indexOf("console") !== -1) return "󰞷";
        if (str.indexOf("code") !== -1 || str.indexOf("edit") !== -1 || str.indexOf("dev") !== -1 || str.indexOf("cursor") !== -1 || str.indexOf("codium") !== -1) return "󰨞";
        if (str.indexOf("file") !== -1 || str.indexOf("folder") !== -1 || str.indexOf("dossier") !== -1 || str.indexOf("nautilus") !== -1) return "󰉋";
        if (str.indexOf("network") !== -1 || str.indexOf("wifi") !== -1 || str.indexOf("server") !== -1 || str.indexOf("ssh") !== -1 || str.indexOf("vnc") !== -1) return "󰛳";
        if (str.indexOf("security") !== -1 || str.indexOf("key") !== -1 || str.indexOf("pass") !== -1 || str.indexOf("pinentry") !== -1 || str.indexOf("prompt") !== -1) return "󰌋";
        if (str.indexOf("hard") !== -1 || str.indexOf("cpu") !== -1 || str.indexOf("topo") !== -1 || str.indexOf("monit") !== -1 || str.indexOf("hwloc") !== -1) return "󰍛";
        if (str.indexOf("video") !== -1 || str.indexOf("media") !== -1 || str.indexOf("audio") !== -1 || str.indexOf("camera") !== -1) return "󰕼";
        if (str.indexOf("setting") !== -1 || str.indexOf("config") !== -1 || str.indexOf("portal") !== -1 || str.indexOf("pref") !== -1) return "󰒓";
        if (str.indexOf("print") !== -1 || str.indexOf("cup") !== -1) return "󰐪";
        return "󰘔";
    }

    // Chargement de l'historique d'utilisation des applications (fréquence MRU).
    // Persistance native via FileView + Quickshell.statePath() (doc Quickshell.Io/FileView &
    // Quickshell/Quickshell v0.3.x) : écriture atomique setText(), plus aucun processus externe.
    FileView {
        id: historyFile
        path: Quickshell.statePath("launcher_history.json")
        blockLoading: true   // fichier minuscule : lecture bloquante acceptable, évite les courses
        printErrors: false   // premier lancement : fichier absent, ne pas polluer les logs

        onLoaded: root.loadHistoryFromView()
        onFileChanged: root.loadHistoryFromView()
    }

    function loadHistoryFromView() {
        var json = historyFile.text();
        if (!json) return;
        try {
            var parsed = JSON.parse(json);
            if (parsed && typeof parsed === "object") {
                root.appHistory = parsed;
            }
        } catch (e) {
            root.appHistory = {};
        }
    }

    function saveHistory() {
        historyFile.setText(JSON.stringify(root.appHistory));
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

        if (app.command && app.command.length > 0) {
            Quickshell.execDetached(["uwsm", "app", "--"].concat(app.command));
        } else if (app.execString) {
            Quickshell.execDetached(["uwsm", "app", "--", app.execString]);
        } else if (typeof app.execute === "function") {
            app.execute();
        }
    }

    function launchCommand(cmd) {
        LauncherService.close();
        if (cmd && cmd.length > 0) {
            Quickshell.execDetached(["uwsm", "app", "--", "kitty", "sh", "-c", cmd + "; exec ${SHELL:-bash}"]);
        } else {
            Quickshell.execDetached(["uwsm", "app", "--", "kitty"]);
        }
    }

    function launchSelected() {
        if (root.isCommandMode) {
            launchCommand(root.commandString);
            return;
        }
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
            // L'historique est chargé par FileView (blockLoading) ; re-synchro défensive
            // au cas où le fichier aurait changé en dehors du shell depuis l'ouverture.
            root.loadHistoryFromView();
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

                    // Icône de recherche Glacier Blue (ou terminal si mode commande)
                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.accent
                        text: root.isCommandMode ? "󰆍" : "󰍉"
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
                            text: "Rechercher une application ou '>' pour une commande..."
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
            // 2. MODE COMMANDE TERMINAL (PRÉFIXE '>')
            // ==========================================
            Rectangle {
                id: commandCard
                visible: root.isCommandMode
                Layout.fillWidth: true
                implicitHeight: cmdCol.implicitHeight + Theme.spacingLg * 2
                radius: Theme.radiusLarge
                color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
                border.color: Theme.accent
                border.width: 1

                ColumnLayout {
                    id: cmdCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacingLg
                    }
                    spacing: Theme.spacingMd

                    // En-tête de la carte terminal
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSm

                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.radiusSmall
                            color: Qt.rgba(0.365, 0.678, 0.886, 0.15)
                            border.color: Theme.accent
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.accent
                                text: "󰆍"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold: true
                                color: Theme.textPrimary
                                text: "Exécuter dans Kitty"
                            }

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                                text: root.commandString !== "" ? "Commande Shell POSIX" : "Tapez la commande à exécuter après le '>'"
                            }
                        }

                        // Badge Touche Entrée
                        Rectangle {
                            height: 24
                            implicitWidth: enterRow.implicitWidth + Theme.spacingSm * 2
                            radius: Theme.radiusSmall
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1

                            RowLayout {
                                id: enterRow
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.accent
                                    text: "󰌑"
                                }

                                Text {
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeTiny
                                    font.bold: true
                                    color: Theme.textPrimary
                                    text: "Entrée"
                                }
                            }
                        }
                    }

                    // Boîte de prévisualisation du prompt terminal
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Theme.radiusSmall
                        color: Qt.rgba(0.02, 0.03, 0.05, 0.90)
                        border.color: Qt.rgba(1, 1, 1, 0.12)
                        border.width: 1

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: Theme.spacingMd
                                rightMargin: Theme.spacingMd
                            }
                            spacing: Theme.spacingSm

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold: true
                                color: Theme.accent
                                text: "$"
                            }

                            Text {
                                Layout.fillWidth: true
                                font.family: "Monospace"
                                font.pixelSize: Theme.fontSizeMedium
                                color: root.commandString !== "" ? Theme.textPrimary : Theme.textDisabled
                                text: root.commandString !== "" ? root.commandString : "echo \"Bonjour monde\""
                                elide: Text.ElideMiddle
                            }
                        }
                    }

                    // Explication
                    Text {
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                        text: "Ouvre une nouvelle fenêtre Kitty, exécute la commande et conserve le shell interactif."
                        wrapMode: Text.WordWrap
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launchSelected()
                }
            }

            // ==========================================
            // 3. GRILLE D'APPLICATIONS (5 COLONNES, ANTI-CLIPPING & CENTRAGE DYNAMIQUE)
            // ==========================================
            Item {
                id: gridContainer
                visible: !root.isCommandMode
                Layout.fillWidth: true
                implicitHeight: Math.min(Math.round(Theme.relHeight(0.55, root.screen)), Math.max(140, Math.ceil(Math.min(10, root.filteredApps.length) / 5.0) * 140))
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

                // Grille avec marges de sécurité anti-clipping et centrage dynamique si moins de 5 éléments
                GridView {
                    id: appGrid
                    visible: root.filteredApps.length > 0
                    model: root.filteredApps

                    // Marges de sécurité latérales évitant tout rognage de bordure lors du grossissement / sélection
                    readonly property int sidePadding: 8
                    readonly property int availableWidth: Math.max(100, gridContainer.width - (sidePadding * 2))
                    readonly property int defaultCellWidth: Math.floor(availableWidth / 5)

                    // Centrage dynamique si moins de 5 éléments
                    width: root.filteredApps.length < 5 ? (root.filteredApps.length * defaultCellWidth) : (defaultCellWidth * 5)
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    cellWidth: defaultCellWidth
                    cellHeight: 140

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
                                margins: 6
                            }
                            radius: Theme.radiusLarge
                            color: (appMouse.containsMouse || isSelected) ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            border.color: isSelected ? Theme.accent : (appMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.16) : "transparent")
                            border.width: isSelected ? 2 : 1
                            scale: (appMouse.containsMouse || isSelected) ? 1.05 : 1.0

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

                                // Conteneur d'icône avec repli visuel garanti
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 52
                                    height: 52

                                    readonly property string iconSrc: root.resolveAppIcon(delegateRoot.modelData)

                                    IconImage {
                                        id: appIconImg
                                        anchors.fill: parent
                                        visible: parent.iconSrc !== ""
                                        source: parent.iconSrc
                                    }

                                    // Badge de remplacement moderne avec icône thématique Nerd Font quand aucune icône image n'est disponible
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.iconSrc === ""
                                        radius: Theme.radiusLarge
                                        color: isSelected ? Qt.rgba(0.365, 0.678, 0.886, 0.22) : Qt.rgba(1, 1, 1, 0.08)
                                        border.color: isSelected ? Theme.accent : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Math.round(Theme.fontSizeTitle * 1.6)
                                            color: isSelected ? Theme.accent : Theme.textSecondary
                                            text: root.getFallbackIcon(delegateRoot.modelData)
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }

                                // Nom de l'application centré sous l'icône, visible uniquement lors de la sélection ou du survol
                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignHCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.textPrimary
                                    text: delegateRoot.modelData.name || "App"
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    opacity: (isSelected || appMouse.containsMouse) ? 1.0 : 0.0

                                    Behavior on opacity { NumberAnimation { duration: Theme.animDurationFast } }
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
