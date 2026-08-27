# Changelog

Toutes les modifications notables apportées à ce projet seront consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au versionnage sémantique.

## [Unreleased]

### Ajouté
- Serveur de notifications D-Bus natif et Centre de Contrôle sous Quickshell v0.3.1 (`notifications/NotificationService.qml`, `notifications/NotificationToastWindow.qml`, `notifications/NotificationCenter.qml`) avec gestion DND, alertes OSD éphémères avec timers d'expiration, curseurs rapides (volume/luminosité) et grille de commandes système (WiFi, Bluetooth, Micro, Audio, Lock, Power).
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
- Fichier `.gitignore` pour exclure les artefacts de travail, configurations d'éditeurs, règles d'agents et secrets.

### Modifié
- Liaison réactive instantanée et zéro polling pour le bouton de notification de la barre (`NotificationButton.qml`) connecté directement au `NotificationService` natif.
- Bascule du raccourci clavier `SUPER + f` dans `binds.lua` vers l'IPC natif Quickshell (`quickshell ipc call notifications toggle`).
- Intégration de `quickshell` dans la table `autostart_commands` de `.config/hypr/programs.lua` avec vérification préalable de présence (`command -v`) et lancement encapsulé sous UWSM (`uwsm app -- quickshell`).
- Dimensionnement 100% relatif et proportionnel en pourcentage d'écran pour la popup MPRIS (`widthPercent: Theme.popupWidthPercentWide`), avec pochette d'album (`coverSize: 72% effectiveWidth`), typographie et commandes multimédia (`btnPlaySize: 28% coverSize`) adaptatives sans pixels fixes.
- Agrandissement des icônes d'applications de la barre des tâches (`20x20px`) dans `TaskbarModule.qml` sans impacter la compacité de la barre.
- Refonte de la disposition de la popup MPRIS (`MprisPopup.qml`) : pochette d'album grand format centrée en haut, métadonnées (titre, artiste, album) centrées en dessous et commandes multimédia élargies en bas.
- Réduction drastique des marges et espacements verticaux (`customPaddingV: 1px`, `barHeightRatio: 0.024`, ~25px) autour des textes et icônes sur l'ensemble des modules de la top barre pour éliminer tout vide inutile.
- Augmentation globale de l'échelle typographique de l'environnement (`Theme.fontSize*` rehaussé de 2px à 4px) et épaississement des barres de progression et curseurs de réglage (`progressBarHeight: 8px`, `progressBarMiniHeight: 6px`) pour une lisibilité accrue sur la barre et les popups.
- Refonte et ajustements des fenêtres popups : affichage du détail par cœur CPU et température dans `CpuPopup`, restauration de la vue multimédia riche MPRIS (`MprisPopup`), restauration de la vue calendrier/horloge complète (`ClockPopup`), passage aux boutons d'actions en icônes pures dans `AppPopup`, et égalisation de la taille des boutons Mute / Panneau dans `VolumePopup`.
- Optimisation compacte de la barre d'état : suppression des marges extérieures pour coller la barre aux bords de l'écran, réduction de la hauteur relative (`barHeightRatio: 0.028`, ~30px) et conservation exclusive de la fine bordure inférieure façon verre (`glassBorder`).
- Remplacement intégral de toutes les valeurs de pixels fixes par un système de dimensionnement relatif et proportionnel à l'écran (`Theme.relWidth`, `Theme.relHeight`, `Theme.moduleWidthPercent*`, `Theme.popupWidthPercent*`, tokens d'espacement et de typographie) assurant une adaptabilité parfaite sur toutes les résolutions (FHD, QHD, 4K, écrans haute densité).
- Transformation de la barre d'état en îlot flottant avec marges natives Wayland layer-shell (`top: 6px`, `left: 8px`, `right: 8px`), coins arrondis (`12px`) et zone d'exclusion dynamique pour les fenêtres Hyprland.
- Épuration complète et minimaliste de l'ensemble des fenêtres flottantes (`bar/popups/*.qml`) : suppression des textes verbeux et listes surchargées, réduction des dimensions et concentration exclusive sur les métriques et actions essentielles.
- Mise à jour du `README.md` (architecture, documentation de la top barre Quickshell, dépendances et procédure d'installation).
- Remplacement de la dépendance `waybar` par `quickshell` dans `.config/hypr/scripts/check-dependencies.sh`.
- Optimisation globale et unification de tous les modules et popups sous l'API native Quickshell v0.3.1 (`Quickshell.execDetached`, `Quickshell.Services.Mpris.trackArtUrl`, `Quickshell.Services.UPower`, `Quickshell.Services.SystemTray`), éliminant tout blocage du thread d'interface et garantissant une exécution asynchrone déterministe.
- Ajout d'une animation fluide de fondu (`opacity`) et de micro-zoom (`scale 0.95 -> 1.0`) à l'ouverture et à la fermeture de toutes les fenêtres flottantes `ModulePopup` (150ms `Easing.OutCubic`).
- Ajustement de l'espace alloué aux modules CPU, RAM et Réseau à 3% de l'écran (`widthPercent: 0.03`) et activation de l'ouverture automatique au survol de la souris (`autoHover`) avec temporisations anti-scintillement sur l'ensemble des popups.
- Adoption d'un dimensionnement responsive en pourcentage relatif d'écran (`widthPercent`) dans `PillButton.qml`, assurant une échelle visuelle fluide et sans décalage quelle que soit la résolution de l'écran (FHD, QHD, 4K).
- Configuration du clic gauche sur le module musique MPRIS pour basculer directement lecture/pause (`playPause()`), clic droit pour afficher le popup multimédia détaillé, clic milieu et molette pour passer aux pistes suivantes/précédentes.
- Ajout et configuration du module `python` dans `.config/starship.toml` pour afficher la version Python et l'environnement virtuel (venv) actif (`$virtualenv`).

### Supprimé
- Suppression définitive du démon et de la configuration SwayNC (`.config/swaync/`) et retrait des dépendances `swaync` et `swaync-client`.
- Suppression définitive du composant et de la configuration Waybar (`.config/waybar/`).

### Corrigé
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
