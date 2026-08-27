# Changelog

Toutes les modifications notables apportées à ce projet seront consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au versionnage sémantique.

## [Unreleased]

### Ajouté
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
- Fichier `.gitignore` pour exclure les artefacts de travail, configurations d'éditeurs, règles d'agents et secrets.

### Modifié
- Ajustement de l'espace alloué aux modules CPU, RAM et Réseau à 3% de l'écran (`widthPercent: 0.03`) et activation de l'ouverture automatique au survol de la souris (`autoHover`) avec temporisations anti-scintillement sur l'ensemble des popups.
- Adoption d'un dimensionnement responsive en pourcentage relatif d'écran (`widthPercent`) dans `PillButton.qml`, assurant une échelle visuelle fluide et sans décalage quelle que soit la résolution de l'écran (FHD, QHD, 4K).
- Configuration du clic gauche sur le module musique MPRIS pour basculer directement lecture/pause (`playPause()`), clic droit pour afficher le popup multimédia détaillé, clic milieu et molette pour passer aux pistes suivantes/précédentes.
- Ajout et configuration du module `python` dans `.config/starship.toml` pour afficher la version Python et l'environnement virtuel (venv) actif (`$virtualenv`).
- Configuration explicite du contrôleur de rétroéclairage (`amdgpu_bl1`) dans SwayNC (`.config/swaync/config.json`).

### Corrigé
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
