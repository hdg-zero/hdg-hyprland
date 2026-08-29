# Changelog

Toutes les modifications notables apportées à ce projet seront consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au versionnage sémantique.

## [Unreleased]

### Ajouté
- Module de Lanceur d'applications natif Quickshell (`.config/quickshell/launcher/` avec `LauncherService.qml`, `LauncherWindow.qml`, `qmldir`) : calque overlay centré occupant 33% de la largeur d'écran, esthétique Obsidian Glass & Glacier Blue reproduisant fidèlement le design Rofi, grille d'applications 5 colonnes avec grandes icônes 52px centrées et hauteur aérée (135px), tri intelligent par fréquence d'utilisation (MRU persistant dans `launcher_history.json`), centrage horizontal dynamique quand la sélection comporte moins de 5 éléments, animation fluide d'ouverture/fermeture avec rebond subtil façon Apple Spotlight (`Easing.OutBack`), recherche instantanée et navigation clavier complète (<kbd>Flèches</kbd>, <kbd>Entrée</kbd>, <kbd>Échap</kbd>, <kbd>Tab</kbd>).
- Décomposition modulaire du Centre de Contrôle sous `.config/quickshell/notifications/components/` avec 4 sous-composants à responsabilité unique : `QuickSettings.qml` (toggles et actions système), `VolumeBrightnessSliders.qml` (curseurs en capsule), `NotificationList.qml` (historique et actions) et `Scratchpad.qml` (bloc-notes persistant).
- Module de Menu de Session plein écran natif Quickshell (`.config/quickshell/session/` avec `SessionService.qml`, `SessionWindow.qml`, `qmldir`) : calque overlay en verre dépoli Obsidian Glass, 6 cartes d'actions centrées avec raccourcis clavier directs (<kbd>L</kbd> Verrouiller, <kbd>U</kbd> Veille, <kbd>E</kbd> Déconnexion, <kbd>H</kbd> Hiberner, <kbd>R</kbd> Redémarrer, <kbd>S</kbd> Éteindre, <kbd>Échap</kbd> Annuler), et gestionnaire IPC dédié (`quickshell ipc call session toggle`).
- Initialisation de la structure de configuration Quickshell v0.3.1 (`.config/quickshell/`) avec `shell.qml`, singleton `Theme.qml` (tokens Obsidian Glass & Glacier Blue) et composants UI réutilisables (`GlassCard`, `PillButton`, `IconLabel`, `ModulePopup`).
- Barre d'état Quickshell complète multi-écrans (`BarWindow`, `BarContent`) intégrant tous les modules : Workspaces, CPU, Mémoire, Réseau, MPRIS, ActiveWindow, Taskbar, SystemTray, Luminosité, Volume, Batterie, Notifications, Horloge et Power.
- Fenêtres flottantes et popups interactives riches (`bar/popups/`) avec ancrage dynamique sous chaque module :
  - `CpuPopup` : Charge CPU, fréquence, température, load average et top 5 des processus CPU.
  - `MemoryPopup` : Utilisation détaillée RAM et Swap, buffers/cache et top 5 des processus mémoire.
  - `NetworkPopup` : Interface active, SSID/signal WiFi, adresses IP/passerelle, débits UP/DOWN en direct et totaux transférés.
  - `MprisPopup` : Pochette d'album haute résolution, titre, artiste, album et contrôles multimédia complets.
  - `VolumePopup` : Curseur de volume interactif (0-150%), détection Bluetooth, presets rapides et raccourci pavucontrol.
  - `BacklightPopup` : Slider interactif de luminosité et presets rapides.
  - `BatteryPopup` : État de charge, estimation d'autonomie, puissance en Watts et sélecteur de profils énergétiques UPower.
  - `ClockPopup` : Horloge détaillée avec secondes, date en français, calendrier du mois dynamique avec jour actif surligné et uptime.
  - `PowerPopup` : Menu rapide de session (Verrouiller, Veille, Redémarrer, Éteindre, Déconnexion).
  - `AppPopup` : Fenêtre flottante interactive d'aperçu d'application au survol des icônes de la barre de tâches (nom de l'app, titre complet de la fenêtre, badge de workspace, état flottant/plein écran, boutons de focus et de fermeture rapide).
- Documentation technique exhaustive de la barre d'état et des popups Quickshell v0.3.1 dans `docs/quickshell-bar.md`.
- Fichier `.gitignore` pour exclure les artefacts de travail, configurations d'éditeurs, règles d'agents, journaux et secrets (`credentials`).

### Modifié
- Remplacement de Rofi par le lanceur d'applications natif Quickshell dans `programs.lua` (`menu`), `binds.lua` (`SUPER + SPACE`) et le bouton de lancement de la barre (`LauncherButton.qml`).
- Simplification de la configuration des écrans dans `monitors.lua` : conservation exclusive des réglages de l'écran principal depuis `profiles/default.lua` (sans machine à états dynamique ni gestion de capot).
- Sécurisation et fiabilisation de l'autostart dans `programs.lua` avec structure conditionnelle `if/then/else` Shell POSIX et suppression des scripts obsolètes commentés.
- Extraction des constantes DRY pour les captures d'écran (`SCREENSHOT_DIR`) dans `binds.lua`.
- Ajout de `jq` dans `check-dependencies.sh` et redirection de la sortie d'erreur vers `stderr`.
- Sécurisation du parsing du niveau de batterie dans `battery-level.sh` et suppression du code mort.
- Fusion des branches de plein écran dans `gesture.sh`.
- Ajout de boutons d'actions rapides en verre dépoli dans la popup réseau (`NetworkPopup.qml`) : bouton **Connexions** (`nm-connection-editor`), bouton **Terminal nmtui** (`kitty -e nmtui`) et bouton **VPN** (`mullvad-gui`).

### Supprimé
- Suppression définitive du composant et de la configuration Rofi (`.config/rofi/`) et retrait de sa dépendance obligatoire dans `check-dependencies.sh`.
- Suppression définitive du script shell obsolète `monitor.sh`.

### Corrigé
- Adoption du type natif `Singleton` (`import Quickshell`) pour tous les singletons du projet (`Theme.qml`, `NotificationService.qml`, `SessionService.qml`), garantissant le bon chargement des tokens de couleur, styles et services.
- Correction de la syntaxe de liaison QML de la propriété `player` dans `MprisPopup.qml` éliminant l'erreur de chargement de configuration.
- Centralisation de la fonction utilitaire de calcul et formatage des débits réseau dans `Theme.qml` (`formatSpeed`), éliminant les duplications dans `NetworkModule.qml` et `NetworkPopup.qml`.
- Élimination de la consommation CPU résiduelle de `ClockPopup.qml` au repos via l'activation conditionnelle du timer (`running: root.visible`) et remplacement des forks `hyprctl` par les dispatchers natifs directs `Hyprland.dispatch` (`Workspaces.qml`, `TaskbarModule.qml`, `AppPopup.qml`).
- Normalisation du pourcentage de batterie (`BatteryPopup.qml`) et synchronisation du lecteur multimédia actif MPRIS entre module et popup avec l'API non dépréciée `trackArtist` (`MprisModule.qml`, `MprisPopup.qml`).
- Unification des actions de session et extinction dans `PowerPopup.qml` et `QuickSettings.qml` via `SessionService`, assurant la conformité UWSM (`uwsm stop`, `uwsm app -- hyprlock`).
- Résolution des conflits de focus exclusif LayerShell en environnement multi-écrans sur `LauncherWindow.qml` et `SessionWindow.qml` en restreignant `WlrKeyboardFocus.Exclusive` au moniteur actif (`Hyprland.focusedMonitor`).
- Suppression du chemin absolu en dur `/home/agent/...` dans la table d'alias d'icônes du lanceur (`LauncherWindow.qml`) et sécurisation du lancement d'applications via la liste typée `app.command` sous `uwsm app --`.
- Ajout du fichier de déclaration de module et singleton `.config/quickshell/notifications/qmldir` garantissant l'instanciation unique et typée du serveur D-Bus `NotificationService` et des fenêtres de notifications.
- Correction de l'instanciation des fenêtres et de la barre d'état sur les écrans connectés à chaud et au démarrage : adoption de blocs `Variants` directs par fenêtre dans `shell.qml` au lieu d'un `Scope` imbriqué, garantissant la création immédiate et fiable de la topbar sur chaque écran (`Quickshell.screens`).
- Correction de la syntaxe de `hyprpaper.conf` avec format plat et directive `preload` obligatoire.
- Élimination des processus Shell périodiques (`date`, `uptime -p`) en boucle chaque seconde dans `SessionWindow.qml` au profit de l'API Date JS et de la lecture native `/proc/uptime` via `FileView`.
- Remplacement du timer 50ms par une `NumberAnimation` fluide pour la jauge de progression dans `NotificationToastWindow.qml`.
- Élimination du polling `wpctl` permanent dans `VolumeModule.qml` grâce au suivi événementiel réactif de `Pipewire.defaultAudioSink.audio`.
- Suppression des notifications vides (sans résumé ni corps) provoquées par les mises à jour DBus `StatusNotifierItem:IconName` de certains processus d'arrière-plan : rejet immédiat dans `NotificationService.qml` et filtrage au niveau du modèle d'affichage dans `NotificationCenter.qml`.
- Élimination des avertissements `Cannot open: qrc:/qt/qml/Quickshell/Widgets/...` sur les icônes d'applications en sécurisant la résolution des chemins via `Quickshell.iconPath` avec support étendu des alias, des noms sans reverse-DNS et un repli propre sur chaîne vide garantissant l'absence de requêtes QRC invalides.
- Élimination des avertissements DBus et requêtes d'icônes manquantes du SystemTray (`nm-no-connection-secure` / `StatusNotifierItem:IconName`) en filtrant les éléments réseaux redondants (`nm-applet`) directement au niveau du modèle dans `SystemTrayModule.qml`.
- Élimination définitive des avertissements QML `Unable to assign a function to a property of any type other than var` dans `NotificationToastWindow.qml` et `NotificationCenter.qml` via la fonction d'aide dédiée `getNotificationActions(notif)` garantissant un type tableau strict pour le modèle de boutons d'actions.
- Correction des plantages et crashes récurrents de Quickshell (SIGSEGV / Pure virtual call `__cxa_pure_virtual` dans `QPlatformPixmap::fromFile` sous Qt 6.11 / Wayland) lors de l'ouverture d'applications ou de notifications : adoption exclusive du composant natif et thread-safe `IconImage` (`Quickshell.Widgets`) dans la barre des tâches (`TaskbarModule.qml`) et les popups d'applications (`AppPopup.qml`), et suppression des chargements asynchrones non thread-safe (`asynchronous: true`).
- Élimination des avertissements QML `Unable to assign a function to a property of any type other than var` dans `NotificationToastWindow.qml` et `NotificationCenter.qml` en passant directement la liste `actions` au modèle du `Repeater` au lieu de `actions.values` (qui résolvait la méthode `Array.prototype.values`).
- Suppression de l'utilisation dépréciée de `height` au profit exclusif de `implicitHeight` sur `PanelWindow` (`BarWindow.qml`) et typage entier strict des marges d'ancrage dans `ModulePopup.qml` éliminant les avertissements QML du runtime.
- Correction de l'analyse `/proc/meminfo` dans `MemoryPopup.qml` via lecture directe `FileView` et expressions régulières, résolvant le problème d'affichage `0/0 Go`.
- Définition explicite de la hauteur de fenêtre `height` et de la zone exclusive Wayland `WlrLayershell.exclusiveZone: height + margins.top + margins.bottom` dans `BarWindow.qml`, garantissant que Hyprland réserve immédiatement l'espace d'affichage nécessaire pour les fenêtres carrelées.
- Élimination du crash `QEventLoop: Cannot be used without QCoreApplication` par suppression du `WheelHandler` Qt redondant au profit de la gestion native `MouseArea.onWheel` et sécurisation des lectures `FileView`.
- Correction des actions de molette de souris sur la barre (workspaces, volume, luminosité, musique) via l'ajout systématique de `import Quickshell` dans tous les modules et normalisation des deltas d'angle.
- Conditionnement du chargement réseau de la pochette d'album (`trackArtUrl`) à la visibilité active de la popup dans `MprisPopup.qml`, éliminant le warning Qt `QIODevice::read (QSslSocket): device not open`.
- Sécurisation des liaisons booléennes `isFloating` et `isFullscreen` dans `AppPopup.qml` pour éliminer l'avertissement QML `Unable to assign [undefined] to bool`.
- Utilisation d'un gestionnaire de pointeur `HoverHandler` non-bloquant sur les fenêtres flottantes `ModulePopup`, empêchant la fermeture prématurée de la fenêtre lors du survol de boutons ou sliders internes.
- Suppression des déclarations redondantes de `parentWindow` dans les modules dérivés de `PillButton`, résolvant l'erreur de chargement QML `Property value set multiple times`.
- Utilisation de la méthode native Quickshell `togglePlaying()` sur `MprisPlayer` au lieu de `playPause()`, éliminant le `TypeError` lors du clic de bascule lecture/pause.
- Définition de la propriété de couleur `accentSecondary` dans `Theme.qml`, éliminant les avertissements QML `Unable to assign [undefined] to QColor` dans `ClockPopup`, `PowerPopup` et `MemoryPopup`.

## [v0.1.1] - 2026-07-22

### Modifié
- Ajustement du sens de défilement de la molette pour le changement de workspace dans `binds.lua` et dans le module Waybar `workspace.jsonc`.
- Désactivation de l'autostart automatique de `monitor.sh` dans `programs.lua`.

## [v0.1.0] - 2026-07-22

### Ajouté
- Machine à états déterministe pour la gestion dynamique des écrans dans `monitors.lua` avec support de l'API Hyprland 0.56 (`hl.get_monitors({ all = true })`).
- Support du profil d'affichage matériel dans `profiles/default.lua`.
- Désactivation automatique de l'écran interne `eDP-1` et bascule exclusive sur l'écran externe lorsque branché (`EXTERNAL_ONLY`).
- Verrouillage de sécurité `SAFETY_FALLBACK` empêchant la perte d'affichage lorsque le capot est fermé sans écran externe.
- Activation native des gestes touchpad (`workspace_swipe = true`) dans `hyprland.lua`.
- Correction de l'erreur Lua `hl.window.resize: 'x' and 'y' are required` dans `binds.lua` en passant les clés `x` et `y` explicites pour le redimensionnement.
- Restauration et enrichissement des raccourcis de redimensionnement et déplacement (`SUPER + ALT_L` / `SUPER + Control_L` au touchpad ainsi que `SUPER + ALT + Flèches` au clavier).
- Option `inhibit_sleep = true` dans `hypridle.conf` pour s'assurer que le verrou `hyprlock` est acquis avant la mise en veille.
- Fichier `CHANGELOG.md` pour le suivi des versions et évolutions du projet.

### Modifié
- Sécurisation de l'action `suspend` dans Wlogout (`wlogout/layout`) avec `loginctl lock-session && systemctl suspend` pour éliminer la condition de course avec `hyprlock`.
- Refonte de `check-dependencies.sh` avec suivi des dépendances obligatoires/optionnelles et code de sortie non-nul (`exit 1`) en cas de manque.
- Nettoyage de `binds.lua` : dossier XDG des captures d'écran (`~/Pictures/Screenshots`), limitation du volume audio à 150%, suppression des drapeaux `locked` non sécurisés.
- Suppression du périphérique `amdgpu_bl1` codé en dur dans SwayNC (`swaync/config.json`) et conversion des commandes `sh -c` en syntaxe POSIX.
- Corrections dans Waybar (`battery.jsonc`, `memory.jsonc`, `network.jsonc`) : suppression d'attributs non standards et corrections typographiques.
- Mise à jour du `README.md` racine et interne pour refléter la compatibilité Hyprland >= 0.56.0.

### Supprimé
- Suppression du script Shell concurrent `monitor.sh`.
- Suppression du script obsolète `gesture.sh`.
