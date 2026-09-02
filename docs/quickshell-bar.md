# 💎 Barre d'État Quickshell (`hdg-quickshell-bar`)

Documentation technique de la barre d'état supérieure et des fenêtres flottantes interactives (**Popups**) développées sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Architecture

La barre d'état Quickshell est déployée dynamiquement sur tous les moniteurs connectés via `Quickshell.screens`.

- **Sobriété énergétique :** 0% CPU au repos sur tous les indicateurs perceptibles, horloge cadencée à la minute (`SystemClock.Minutes`), zéro polling sur PipeWire (`PwObjectTracker`) et lazy-loading des processus lourds dans les popups (`running: root.visible`). La persistance (historique du lanceur, bloc-notes) passe par `FileView` + `Quickshell.statePath()` — aucun processus externe.
- **Design Obsidian Glass & Glacier Blue :** Fond sombre translucide (`Theme.background`), fine bordure inférieure (`Theme.glassBorder`) et dimensionnement 100% relatif (`Theme.barHeightRatio`, `Theme.relWidth`).
- **Découpage modulaire :** [`BarContent.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/bar/BarContent.qml) structure 3 sous-sections indépendantes sous `.config/quickshell/bar/sections/` :
  - **`LeftSection.qml`** : Lanceur, Workspaces, métriques matérielles (CPU, RAM, Réseau) et lecteur multimédia MPRIS.
  - **`CenterSection.qml`** : Titre épuré de l'application active (`ActiveWindow`).
  - **`RightSection.qml`** : Barre des tâches (`TaskbarModule`), System Tray, curseurs et jauges (Luminosité, Volume, Batterie, Notifications, Horloge, Power).

---

## 🏛️ 2. Arborescence du Module `bar/`

```
.config/quickshell/bar/
├── BarWindow.qml            # Fenêtre PanelWindow WlrLayershell (Top, Zone exclusive)
├── BarContent.qml           # Disposition globale des sections
├── qmldir                   # Déclaration de module
├── sections/                # Sous-sections modulaires de la barre
│   ├── LeftSection.qml      # Section Gauche (Système & Navigation)
│   ├── CenterSection.qml    # Section Centre (Fenêtre active)
│   ├── RightSection.qml     # Section Droite (Tâches & Contrôle matériel)
│   └── qmldir               # Déclaration de module
├── modules/                 # Composants visibles dans la barre
│   ├── LauncherButton.qml   # Bouton lanceur (LauncherService.toggle)
│   ├── Workspaces.qml       # Sélecteur de workspaces Hyprland
│   ├── CpuModule.qml        # Jauge et charge CPU (3.8% écran)
│   ├── MemoryModule.qml     # Jauge et utilisation RAM (3.8% écran)
│   ├── NetworkModule.qml    # Statut connexion et débits (3.8% écran)
│   ├── MprisModule.qml      # Lecteur musical MPRIS (12% écran)
│   ├── ActiveWindow.qml     # Titre de la fenêtre active
│   ├── TaskbarModule.qml    # Barre de tâches avec icônes d'applications ouvertes
│   ├── SystemTrayModule.qml # Zone de notification système SNI filtrée
│   ├── BacklightModule.qml  # Jauge de rétroéclairage
│   ├── VolumeModule.qml     # Jauge de volume PipeWire réactive
│   ├── BatteryModule.qml    # Jauge de batterie UPower
│   ├── NotificationButton.qml # Cloche de notifications & badge DND
│   ├── ClockModule.qml      # Horloge système cadencée à la minute
│   ├── PowerButton.qml      # Menu d'extinction rapide
│   └── qmldir               # Déclaration de module
└── popups/                  # Fenêtres flottantes interactives (survol / clic)
    ├── AppPopup.qml         # Aperçu d'application, badges d'état et action Fermer
    ├── BacklightPopup.qml   # Curseur de luminosité et presets rapides
    ├── BatteryPopup.qml     # Débit Watts, autonomie estimée et profils UPower
    ├── ClockPopup.qml       # Calendrier dynamique du mois, secondes et uptime
    ├── CpuPopup.qml         # Charge globale, charge par cœur et température
    ├── MemoryPopup.qml      # RAM et Swap détaillés (Go et pourcentages)
    ├── MprisPopup.qml       # Pochette HD centrée et contrôles multimédias
    ├── NetworkPopup.qml     # IP, passerelle, débits et boutons nmtui/VPN
    ├── PowerPopup.qml       # Menu compact d'extinction rapide
    ├── VolumePopup.qml      # Curseur 0-150%, muet et raccourci pavucontrol
    └── qmldir               # Déclaration de module
```

---

## 🎨 3. Design Tokens & Ratios (`Theme.qml`)

| Token | Valeur | Rôle |
|:---|:---|:---|
| `background` | `rgba(11, 15, 20, 0.88)` | Fond principal Obsidian Glass de la barre |
| `cardBackground` | `rgba(18, 25, 32, 0.94)` | Fond des popups flottantes et cartes |
| `cardBackgroundHover` | `rgba(35, 47, 60, 0.98)` | Fond des éléments interactifs au survol |
| `glassBorder` | `rgba(93, 173, 226, 0.25)` | Bordure subtile façon verre (Glacier Blue) |
| `accent` | `#5dade2` | Couleur d'accent principale (Glacier Blue) |
| `accentSecondary` | `#85c1e9` | Couleur d'accent secondaire (Glacier Light Blue) |
| `barHeightRatio` | `0.024` | Ratio de hauteur relative de la barre (~25px en 1080p, ~34px en 1440p) |
| `notificationPanelWidth` | `480` | Largeur fixe standardisée du Centre de Contrôle (haut-centré) |
| `notificationToastWidth` | `380` | Largeur fixe standardisée des toasts de notifications OSD |
| `moduleWidthPercentMetrics` | `0.038` | Largeur relative des modules CPU / RAM / Réseau (3.8% écran) |
| `moduleWidthPercentMpris` | `0.12` | Largeur relative du lecteur multimédia (12% écran) |
---

## 🕹️ 4. Détail des Sections & Popups

### 📌 Section Gauche (`LeftSection.qml`)
- **󰣇 Lanceur (`LauncherButton`) :** Déclenche `LauncherService.toggle()` (ou <kbd>SUPER</kbd> + <kbd>Espace</kbd>).
- **Workspaces (`Workspaces`) :** Affichage réactif des bureaux Hyprland avec bascule au clic gauche et défilement à la molette.
- **󰻠 CPU (`CpuModule` + `CpuPopup`) :** Charge en direct (3.8% écran), popup avec jauge fine, température (``), détail par cœur et Top 5 CPU.
- **󰍛 Mémoire (`MemoryModule` + `MemoryPopup`) :** Consommation RAM (3.8% écran), popup avec répartition RAM/Swap et Top 5 Mémoire.
- **󰤨 Réseau (`NetworkModule` + `NetworkPopup`) :** Signal Wi-Fi/Filaire (3.8% écran), popup avec IP locale, passerelle, débits UP/DOWN et boutons d'actions rapides (**Connexions**, **Terminal nmtui**, **VPN**).
- **󰝚 Lecteur MPRIS (`MprisModule` + `MprisPopup`) :** Titre défilant (12% écran), contrôles au clic (Lecture/Pause, Piste suivante/précédente), popup avec pochette HD centrée.

### 📌 Section Centre (`CenterSection.qml`)
- **Fenêtre Active (`ActiveWindow`) :** Titre épuré de l'application au premier plan.

### 📌 Section Droite (`RightSection.qml`)
- **Barre des Tâches (`TaskbarModule` + `AppPopup`) :** Icônes des fenêtres ouvertes avec rendu thread-safe `IconImage`. Popup au survol avec statut plein écran/flottant, workspace assigné et boutons Focus/Fermer.
- **System Tray (`SystemTrayModule`) :** Zone de notification SNI native Wayland filtrée.
- **󰃠 Luminosité (`BacklightModule` + `BacklightPopup`) :** Réglage à la molette (pas de 3%), popup avec slider 1-100% et presets.
- **󰕾 Volume Audio (`VolumeModule` + `VolumePopup`) :** Réglage à la molette (pas de 5%), popup avec slider 0-150% PipeWire et mixeur Pavucontrol.
- **󰁹 Batterie (`BatteryModule` + `BatteryPopup`) :** Détection automatique (masqué sur PC fixe), popup avec autonomie, débit en Watts et profils UPower (**Éco**, **Équilibré**, **Max**).
- **󰂚 Centre de Contrôle (`NotificationButton`) :** Ouvre le Centre de Contrôle Quickshell (`NotificationService.togglePanel()`), badge du nombre de notifications non lues.
- **󰥔 Horloge (`ClockModule` + `ClockPopup`) :** Heure `HH:mm` cadencée à la minute, popup avec calendrier complet du mois et uptime.
- **⏻ Menu Énergie (`PowerButton` + `PowerPopup`) :** Clic gauche pour menu rapide compact, clic droit pour le Menu de Session plein écran.

---

## ⚡ 5. Modèle d'Interaction, Lazy Loading & Destroy-on-Close

Dans [`LazyPopup.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/components/LazyPopup.qml) et [`ModulePopup.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/components/ModulePopup.qml) :
- **Instanciation Paresseuse & Destroy-on-Close :** Les 10 popups de la barre ne sont pas maintenues en mémoire vive. Le composant `LazyPopup` n'instancie la surface `PopupWindow` et ses vues QML qu'à l'entrée du curseur (`hoverRequested`) ou au clic (`clickRequested`), et détruit immédiatement l'instance dès la fin de l'animation de fermeture (`onFullyClosed`).
- **Délai d'ouverture anti-spam (`140 ms`) :** Évite les instanciations et ouvertures accidentelles lors d'un simple balayage rapide du curseur.
- **Délai de fermeture fluide (`320 ms`) :** Permet la transition naturelle du curseur entre le bouton de la barre et la popup flottante sans rupture d'ancrage.
- **Animations cubiques fluides :** Fondu d'opacité `0.0 ➔ 1.0` en 150ms (`Easing.OutCubic`) et micro-zoom d'apparition `0.95 ➔ 1.0`.
- **Flou Matériel Natif Hyprland :** Surfaces associées au namespace `qs-popup` avec `layerrule = blur, ignorezero` dans `hyprland.lua`.
