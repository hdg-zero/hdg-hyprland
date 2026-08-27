# 💎 Barre d'État Quickshell (`hdg-quickshell-bar`)

Documentation technique et guide d'architecture de la barre d'état et des fenêtres flottantes interactives développées sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Objectifs

La barre d'état Quickshell remplace l'ancienne implémentation statique Waybar. Ses objectifs fondamentaux sont :
- **Sobriété énergétique & performances maximales :** Empreinte RAM minimale (< 25 Mo), zéro réveil processeur inutile au repos (0% CPU idle).
- **Interactivité riche :** Chaque module de la barre dispose d'une fenêtre flottante (**Popup**) détaillée et interactive qui s'ouvre au survol ou au clic.
- **Design Obsidian Glass & Glacier Blue :** Esthétique moderne "Liquid Glass" sombre et translucide avec bordures subtiles et accents bleu glacier.
- **Support Multi-Écrans Natif :** Déploiement automatique et dynamique sur tous les moniteurs connectés via `Quickshell.screens`.
- **Dimensionnement Responsive :** Échelle proportionnelle à la résolution d'écran (`widthPercent`) sans décalage ni saut visuel lors des variations de charge ou de format.

---

## 🏛️ 2. Architecture & Arborescence

L'ensemble de la configuration réside dans `.config/quickshell/` :

```
.config/quickshell/
├── shell.qml                    # Point d'entrée principal ShellRoot (Multi-moniteurs)
├── theme/                       # Design tokens & Thème
│   ├── Theme.qml                # Singleton de couleurs, typographie, espacements et animations
│   └── qmldir                   # Déclaration du module Theme
├── components/                  # Composants graphiques réutilisables
│   ├── GlassCard.qml            # Carte de fond translucide avec flou et bordure
│   ├── PillButton.qml           # Bouton pilule responsive (% largeur écran, icône + texte)
│   ├── IconLabel.qml            # Label combiné icône/texte avec animation de couleur
│   ├── ModulePopup.qml          # Fenêtre flottante PopupWindow (survol intelligent, fondu)
│   └── qmldir                   # Déclaration du module Components
├── notifications/               # Serveur de notifications natif & Centre de Contrôle
│   ├── NotificationService.qml  # Singleton D-Bus (NotificationServer), état DND, historique, IPC
│   ├── NotificationToastWindow.qml # Fenêtre de toasts flottants OSD avec compte à rebours
│   ├── NotificationCenter.qml   # Centre de Contrôle Glassmorphism (toggles Apple, sliders, historique, bloc-notes)
│   └── qmldir                   # Déclaration du module Notifications
├── session/                     # Menu de session plein écran natif (Power Menu)
│   ├── SessionService.qml       # Singleton d'état, helper d'actions et IpcHandler
│   ├── SessionWindow.qml        # Fenêtre plein écran Obsidian Glass avec raccourcis directs
│   └── qmldir                   # Déclaration du module Session
└── bar/                         # Barre d'état
    ├── BarWindow.qml            # Fenêtre PanelWindow WlrLayershell (Top)
    ├── BarContent.qml           # Disposition des 3 sections (Gauche, Centre, Droite)
    ├── qmldir                   # Déclaration du module Bar
    ├── modules/                 # Modules visibles dans la barre
    │   ├── LauncherButton.qml   # Lanceur d'applications Rofi
    │   ├── Workspaces.qml       # Sélecteur de workspaces Hyprland
    │   ├── CpuModule.qml        # Jauge et charge CPU (3.8% écran)
    │   ├── MemoryModule.qml     # Jauge et utilisation RAM (3.8% écran)
    │   ├── NetworkModule.qml    # État connexion et débits (3.8% écran)
    │   ├── MprisModule.qml      # Lecteur musical MPRIS (12% écran)
    │   ├── ActiveWindow.qml     # Titre de la fenêtre active
    │   ├── TaskbarModule.qml    # Barre de tâches avec icônes d'applications ouvertes
    │   ├── SystemTrayModule.qml # Zone de notification système (System Tray)
    │   ├── BacklightModule.qml  # Jauge de rétroéclairage
    │   ├── VolumeModule.qml     # Jauge de volume audio PipeWire/WirePlumber
    │   ├── BatteryModule.qml    # Jauge de batterie UPower
    │   ├── NotificationButton.qml # Centre de notifications & badge réactif DND
    │   ├── ClockModule.qml      # Horloge à la minute (SystemClock)
    │   ├── PowerButton.qml      # Menu de session et énergie
    │   └── qmldir               # Déclaration du module Modules
    └── popups/                  # Fenêtres flottantes interactives
        ├── AppPopup.qml         # Aperçu d'application, badges d'état et actions Focus/Fermer
        ├── BacklightPopup.qml   # Curseur de luminosité et presets rapides
        ├── BatteryPopup.qml     # Taux de décharge/charge, temps restant et profils UPower
        ├── ClockPopup.qml       # Horloge précise, calendrier dynamique du mois et uptime
        ├── CpuPopup.qml         # Température, détail par cœur, load average et Top 5 processus
        ├── MemoryPopup.qml      # RAM, Swap détaillé et Top 5 processus RAM
        ├── MprisPopup.qml       # Pochette d'album HD centrée, métadonnées et contrôles complets
        ├── NetworkPopup.qml     # IP locale, passerelle, débits UP/DOWN et totaux session
        ├── PowerPopup.qml       # Verrouiller, Veille, Redémarrer, Éteindre, Déconnexion
        ├── VolumePopup.qml      # Curseur 0-150%, presets rapides, mute et mixeur Pavucontrol
        └── qmldir               # Déclaration du module Popups
```

---

## 🎨 3. Design System (`Theme.qml`)

Le design system repose sur une palette sombre et épurée inspirée du verre fumé :

| Token | Valeur | Rôle |
| :--- | :--- | :--- |
| `background` | `#e00b0f14` | Fond principal de la barre (Obsidian Glass 88% opacité) |
| `cardBackground` | `#f0121920` | Fond des cartes flottantes et popups (94% opacité) |
| `cardBackgroundHover` | `#fa232f3c` | Fond des éléments au survol (98% opacité) |
| `glassBorder` | `#405dade2` | Bordure subtile façon verre (Glacier Blue 25% opacité) |
| `accent` | `#5dade2` | Couleur d'accent principale (Glacier Blue) |
| `accentSecondary` | `#85c1e9` | Couleur d'accent secondaire (Glacier Light Blue) |
| `success` | `#2ecc71` | Vert pour statut connecté / validation |
| `warning` | `#ffb86c` | Orange ambre pour le mode DND / alertes |
| `destructive` | `#ff6b6b` | Rouge pour mute micro/audio, fermeture, extinction |
| `fontFamily` | `"JetBrainsMono Nerd Font", monospace` | Police principale pour l'interface et les icônes |
| `barHeightRatio` | `0.024` | Hauteur relative fine de la top barre (~25px en 1080p, ~34px en 1440p) |
| `progressBarHeight` | `8px` | Épaisseur des jauges et curseurs de progression |
| `moduleWidthPercentMetrics` | `0.038` | Largeur relative des modules CPU / RAM / Réseau (3.8% de l'écran) |
| `moduleWidthPercentMpris` | `0.12` | Largeur relative du module Musique (12% de l'écran) |
| `popupWidthPercent*` | `0.11 ➔ 0.16` | Largeurs relatives des fenêtres popups (11% à 16% de l'écran) |

---

## 🕹️ 4. Modules et Fenêtres Flottantes (Popups)

### 📌 4.1 Section Gauche (Système & Navigation)
- **󰣇 Lanceur (`LauncherButton`) :** Déclenche `rofi -show drun`.
- **Workspaces (`Workspaces`) :** 
  - Affiche les bureaux actifs et occupés.
  - Clic gauche : Bascule sur le bureau sélectionné.
  - Molette souris : Navigation séquentielle `e-1` / `e+1`.
- **󰻠 CPU (`CpuModule` + `CpuPopup`) :**
  - Barre : Largeur fixée à 3.8% de l'écran (`widthPercent: 0.038`).
  - Popup épuré : Jauge fine, pourcentage, température matérielle (``), détail par cœur et load average (``).
- **󰍛 Mémoire (`MemoryModule` + `MemoryPopup`) :**
  - Barre : Largeur fixée à 3.8% de l'écran (`widthPercent: 0.038`).
  - Popup épuré : Jauge fine, pourcentage, RAM utilisée / totale et pourcentage Swap.
- **󰤨 Réseau (`NetworkModule` + `NetworkPopup`) :**
  - Barre : Largeur fixée à 3.8% de l'écran (`widthPercent: 0.038`).
  - Popup épuré : Nom du WiFi / Filaire + signal, adresse IP locale et débits instantanés (↓/↑).
- **󰝚 Lecteur Multimédia (`MprisModule` + `MprisPopup`) :**
  - Barre : Largeur fixée à 12% de l'écran (`widthPercent: 0.12`) avec défilement/troncature propre.
  - Clic gauche : Lecture / Pause immédiate (`togglePlaying()`).
  - Clic droit : Ouvre la popup détaillée.
  - Clic milieu & Molette : Piste suivante / précédente.
  - Popup épuré : Pochette d'album HD grand format centrée, titre, artiste, album et contrôles multimédias 100% relatifs.

### 📌 4.2 Section Centre
- **Fenêtre Active (`ActiveWindow`) :** Titre épuré de l'application en cours de focus.

### 📌 4.3 Section Droite (Tâches & Contrôle Matériel)
- **Barre des Tâches (`TaskbarModule` + `AppPopup`) :**
  - Affiche les icônes haute résolution des fenêtres ouvertes sous Hyprland avec espacement respirant (`spacing: 10px`).
  - Clic gauche : Focus et passage au premier plan de l'application.
  - Clic milieu : Fermeture de la fenêtre.
  - **Popup d'Aperçu au survol (`AppPopup`) :**
    - Nom de l'application, badge de workspace assigné, titre de fenêtre sur une ligne et boutons compacts **󰘳 Basculer** (focus) et **󰅖 Fermer**.
- **System Tray (`SystemTrayModule`) :** Zone de notification SNI native Wayland avec support clic gauche, clic droit et molette.
- **󰃠 Luminosité (`BacklightModule` + `BacklightPopup`) :**
  - Molette sur la barre : Ajustement par pas de 3%.
  - Popup épuré : Curseur interactif 1-100% et presets rapides (25%, 50%, 75%, 100%).
- **󰕾 Volume Audio (`VolumeModule` + `VolumePopup`) :**
  - Molette sur la barre : Ajustement par pas de 5%.
  - Clic droit : Ouvre le mixeur `pavucontrol`.
  - Popup épuré : Curseur interactif 0-150% PipeWire, bouton Muet et raccourci mixeur `󰓃`.
- **󰁹 Batterie (`BatteryModule` + `BatteryPopup`) :**
  - Détection automatique (masqué sur PC fixe).
  - Popup épuré : Jauge fine, pourcentage, temps restant estimé, débit en Watts et sélecteur de profils UPower (**Éco**, **Équilibré**, **Max**).
- **󰂚 Centre de Contrôle & Notifications (`NotificationButton` + `NotificationCenter`) :**
  - Clic gauche : Ouvre/Ferme le Centre de Contrôle natif Quickshell (`NotificationService.togglePanel()`).
  - Clic droit : Bascule le mode Ne Pas Déranger (`NotificationService.toggleDnd()`).
  - Badge dynamique en temps réel sans polling affichant le nombre de notifications non lues.
  - Toasts OSD flottants (`NotificationToastWindow`) avec compte à rebours de fermeture automatique.
- **󰥔 Horloge (`ClockModule` + `ClockPopup`) :**
  - Barre : Heure au format `HH:mm` cadencée à la minute.
  - Popup épuré : Heure avec secondes, date en français, calendrier compact du mois avec jour courant en surbrillance et Uptime système.
- **⏻ Menu Énergie (`PowerButton` + `PowerPopup`) :**
  - Clic gauche : Menu rapide compact (Verrouiller, Veille, Déconnexion, Redémarrer, Éteindre).
  - Clic droit : Ouvre le Menu de Session plein écran natif (`SessionService.toggleSession()`).

---

## ⚡ 5. Modèle d'Interaction & Confort Visuel

### ⏱️ Survol Intelligent & Anti-Scintillement
Dans [`ModulePopup.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/components/ModulePopup.qml), la gestion du survol est orchestrée avec précision :
- **Délai d'ouverture (`140 ms`) :** Empêche l'ouverture intempestive lors du simple passage rapide de la souris.
- **Délai de fermeture (`320 ms`) :** Laisse à l'utilisateur le temps de déplacer le curseur de la barre vers la popup sans la fermer.
- **`HoverHandler` non-bloquant :** Maintient la popup ouverte même lors de l'interaction avec des boutons internes, sliders ou listes d'éléments.

### 🎬 Animations Fluides
Toutes les transitions d'ouverture et de fermeture utilisent des courbes cubiques réactives :
- **Fondu d'opacité :** `0.0 ➔ 1.0` en 150 ms (`Easing.OutCubic`).
- **Micro-zoom d'apparition :** `scale: 0.95 ➔ 1.0` ancré sur le haut de la fenêtre.

---

## 🔋 6. Optimisations de Performance & Sobriété Énergétique

1. **Lazy-loading strict des processus système :**
   Les commandes lourdes (`ps -eo ...`, `cat /proc/meminfo`, lectures d'interfaces réseau) sont rattachées à la propriété `running: root.visible`. Elles ne consomment aucun cycle CPU tant que le popup associé n'est pas ouvert par l'utilisateur.
2. **Horloge cadencée à la minute :**
   Utilisation de `SystemClock` avec `precision: SystemClock.Minutes` sur la barre principale pour éliminer les réveils de timers chaque seconde.
3. **Exécution Asynchrone `Quickshell.execDetached` :**
   Toutes les interactions et lancements de commandes externes (`hyprctl`, `wpctl`, `brightnessctl`, `powerprofilesctl`, `rofi`) sont exécutés de façon asynchrone et détachée, prévenant tout blocage du thread graphique de rendu.

---

## 🔔 7. Architecture du Serveur de Notifications & Centre de Contrôle Natif

Le sous-système de notifications réside dans `.config/quickshell/notifications/` et remplace intégralement SwayNC :

### 1. `NotificationService.qml` (Singleton D-Bus)
- **Serveur D-Bus natif :** Instancie `Quickshell.Services.Notifications.NotificationServer` qui revendique le nom de bus standard `org.freedesktop.Notifications`.
- **Gestionnaire DND (Ne Pas Déranger) :** Filtre l'affichage des alertes visuelles tout en conservant l'historique complet dans `trackedNotifications`.
- **Handler IPC & Raccourcis :** Enregistre une cible IPC (`target: "notifications"`) permettant le contrôle par scripts et binds Hyprland :
  ```bash
  quickshell ipc call notifications toggle
  quickshell ipc call notifications toggleDnd
  quickshell ipc call notifications clear
  ```

### 2. `NotificationToastWindow.qml` (Toasts Flottants OSD)
- Fenêtre en calque `Overlay` affichant les notifications entrantes dans le coin supérieur droit.
- Barre de progression d'expiration visuelle (5s normale, 3.5s basse priorité, infinie pour les alertes critiques).
- Mise en pause automatique du compte à rebours au survol de la souris.

### 3. `NotificationCenter.qml` (Centre de Contrôle Glassmorphism)
- **Design épuré style Apple Control Center :**
  - **Toggles rapides sans texte :** Pavés tactiles à grandes icônes centrées (Wi-Fi, Bluetooth, Micro, Audio).
  - **Curseurs en capsule :** Curseurs horizontaux de volume et luminosité avec icône intégrée et pourcentage dynamique.
  - **Actions système :** Boutons compacts Verrouiller (`hyprlock`) et Session (`SessionService.openSession()`).
  - **Mini Bloc-Notes persistant (Scratchpad) :** Zone d'édition défilante avec persistance synchrone débouncée dans `scratchpad.txt` et boutons Copier / Purger.
  - **Historique & Actions :** Liste défilante des notifications avec suppression unitaire ou globale (`󰃢`).
- **100% Dimensionnement Relatif :** Largeur fixée à 12.5% de l'écran (`Theme.relWidth(0.125, screen)`), hauteur dynamique adaptée au contenu.

---

## 🚪 8. Architecture du Menu de Session Plein Écran Natif

Le module de session réside dans `.config/quickshell/session/` et remplace intégralement `wlogout` :

### 1. `SessionService.qml` (Singleton d'État & IPC)
- Maintient la visibilité du menu de session (`sessionVisible`).
- Expose l'API de contrôle système (`lock()`, `suspend()`, `logout()`, `hibernate()`, `reboot()`, `shutdown()`).
- Handler IPC (`target: "session"`) pour le contrôle Hyprland (`SUPER + M`) :
  ```bash
  quickshell ipc call session toggle
  quickshell ipc call session open
  quickshell ipc call session close
  ```

### 2. `SessionWindow.qml` (Fenêtre Plein Écran Glassmorphism)
- **Calque Overlay avec Focus Exclusif :** `WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive` capture immédiatement toutes les touches dès l'ouverture.
- **Raccourcis Clavier Directs :**
  - <kbd>L</kbd> : Verrouiller (`hyprlock`)
  - <kbd>U</kbd> : Veille (`loginctl lock-session && systemctl suspend`)
  - <kbd>E</kbd> : Déconnexion (`uwsm stop`)
  - <kbd>H</kbd> : Hiberner (`systemctl hibernate`)
  - <kbd>R</kbd> : Redémarrer (`systemctl reboot`)
  - <kbd>S</kbd> : Éteindre (`systemctl poweroff`)
  - <kbd>Échap</kbd> ou **Clic extérieur** : Fermeture instantanée du menu.
- **Cartes Obsidian Glass :** 6 grandes cartes tactiles animées au survol avec halo de couleur et micro-scale responsive.

