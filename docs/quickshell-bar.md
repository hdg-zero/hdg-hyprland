# 💎 Barre d'État Quickshell (`hdg-quickshell-bar`)

Documentation technique de la barre d'état supérieure et des fenêtres flottantes interactives (**Popups**) développées sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Architecture

La barre d'état Quickshell est déployée dynamiquement sur tous les moniteurs connectés via `Quickshell.screens`.

- **Rafraîchissements :** Horloge cadencée à la minute (`SystemClock.Minutes`), volume réactif avec PipeWire (`PwObjectTracker`) et chargement à la demande des popups (`running: root.isOpen`). Les périodes des métriques de la barre sont conservées ; aucun gain CPU chiffré n’est annoncé.
- **Design Obsidian & ardoise :** Fond ardoise uni, bordure neutre de 1 px, accent bleu grisé `#8297a6` et texte sans-serif. `BarStyle.qml` reprend la palette du panneau ; les glyphes gardent leur police Nerd Font et le lanceur son icône Arch. La hauteur reste `max(24, round(hauteurLogique × 0.024))`, avec la même zone exclusive.
- **Découpage modulaire :** [`BarContent.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/bar/BarContent.qml) structure 3 sous-sections indépendantes sous `.config/quickshell/bar/sections/` :
  - **`LeftSection.qml`** : Lanceur, Workspaces, métriques matérielles (CPU, RAM, Réseau) et lecteur multimédia MPRIS.
  - **`CenterSection.qml`** : Titre épuré de l'application active (`ActiveWindow`).
  - **`RightSection.qml`** : Barre des tâches (`TaskbarModule`), System Tray, curseurs et jauges (Luminosité, Volume, Batterie, Notifications, Horloge, Power).

---

## 🏛️ 2. Arborescence du Module `bar/`

```
.config/quickshell/bar/
├── BarWindow.qml            # Fenêtre PanelWindow WlrLayershell (Top, Zone exclusive)
├── BarContent.qml           # Disposition globale, titre borné à l’espace libre
├── BarStyle.qml             # Palette ardoise et budgets de largeur
├── components/
│   ├── BarPillButton.qml     # Style local, noms accessibles ; actions conservées
│   └── qmldir
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
│   ├── NetworkModule.qml    # Statut connexion et débits (6.8% écran)
│   ├── MprisModule.qml      # Lecteur musical MPRIS (12% écran)
│   ├── ActiveWindow.qml     # Titre de la fenêtre active
│   ├── TaskbarModule.qml    # Icônes natives, débordement horizontal et focus visible
│   ├── SystemTrayModule.qml # Zone de notification système SNI filtrée
│   ├── CaffeineModule.qml   # Module Caféine (anti-sommeil, inhibition Wayland)
│   ├── BacklightModule.qml  # Jauge de rétroéclairage
│   ├── VolumeModule.qml     # Jauge de volume PipeWire réactive
│   ├── BatteryModule.qml    # Jauge de batterie UPower
│   ├── NotificationButton.qml # Cloche de notifications & badge DND
│   ├── ClockModule.qml      # Horloge système cadencée à la minute
│   ├── PowerButton.qml      # Menu d'extinction rapide
│   └── qmldir               # Déclaration de module
└── popups/                  # Fenêtres flottantes interactives (survol / clic)
    ├── AppPopup.qml         # Aperçu d'application, badges d'état et action Fermer
    ├── ClockPopup.qml       # Calendrier dynamique du mois, secondes et uptime
    ├── MprisPopup.qml       # Pochette HD centrée et contrôles multimédias
    ├── NetworkPopup.qml     # Adresse locale, débits ↑/↓ et boutons nmtui/VPN
    ├── PowerPopup.qml       # Menu compact d'extinction rapide
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
| `moduleWidthPercentMetrics` | `0.038` | Largeur relative des modules CPU / RAM (3.8% écran) |
| `moduleWidthPercentNetwork` | `0.068` | Largeur relative du module Réseau Wi-Fi/Filaire (6.8% écran, +3% pour débits) |
| `moduleWidthPercentMpris` | `0.12` | Largeur relative du lecteur multimédia (12% écran) |
---

## 🕹️ 4. Détail des Sections & Popups

### 📌 Section Gauche (`LeftSection.qml`)
- **󰣇 Lanceur (`LauncherButton`) :** Déclenche `LauncherService.toggle()` (ou <kbd>SUPER</kbd> + <kbd>Espace</kbd>).
- **Workspaces (`Workspaces`) :** Affichage réactif des bureaux Hyprland avec bascule au clic gauche et défilement à la molette.
- **󰻠 CPU (`CpuModule`) :** Charge en direct (3.8% écran), btop au clic droit.
- **󰍛 Mémoire (`MemoryModule`) :** Consommation RAM (3.8% écran), btop au clic droit.
- **󰤨 Réseau (`NetworkModule` + `NetworkPopup`) :** Signal Wi-Fi/Filaire (6.8% écran), popup avec SSID, signal et débits de l’interface affichée ; IP locale directement visible et commandes Connexions, nmtui et VPN par icônes.
- **󰝚 Lecteur MPRIS (`MprisModule` + `MprisPopup`) :** Titre défilant (12% écran), contrôles au clic (Lecture/Pause, Piste suivante/précédente), popup avec pochette de 64 px, titre/artiste/album et trois commandes natives.

### 📌 Section Centre (`CenterSection.qml`)
- **Fenêtre Active (`ActiveWindow`) :** Titre épuré de l'application au premier plan.

### 📌 Section Droite (`RightSection.qml`)
- **Barre des Tâches (`TaskbarModule` + `AppPopup`) :** Icônes des fenêtres ouvertes avec rendu thread-safe `IconImage`. Popup au survol avec statut plein écran/flottant, workspace assigné et boutons Focus/Fermer.
- **System Tray (`SystemTrayModule`) :** Zone de notification SNI native Wayland filtrée.
- **󰅶 Mode Caféine (`CaffeineModule`) :** Bascule directe au clic du maintien de l'écran allumé (inhibition Wayland native `idle-inhibit-unstable-v1`).
- **󰃠 Luminosité (`BacklightModule`) :** Réglage à la molette (pas de 3%).
- **󰕾 Volume Audio (`VolumeModule`) :** Réglage à la molette (pas de 5%), mixeur Pavucontrol au clic droit.
- **󰁹 Batterie (`BatteryModule`) :** Pourcentage et état de charge UPower, masqué en l’absence de batterie.
- **󰂚 Centre de Contrôle (`NotificationButton`) :** Ouvre le Centre de Contrôle Quickshell (`NotificationService.togglePanel()`), badge du nombre de notifications non lues.
- **󰥔 Horloge (`ClockModule` + `ClockPopup`) :** Heure `HH:mm` cadencée à la minute, popup avec calendrier complet du mois et uptime.
- **⏻ Menu Énergie (`PowerButton` + `PowerPopup`) :** Clic gauche ou droit pour les cinq actions du menu rapide compact.

---

## ⚡ 5. Modèle d'Interaction, Lazy Loading & Destroy-on-Close

Dans [`LazyPopup.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/components/LazyPopup.qml) et [`ModulePopup.qml`](file:///Projets/github/hdg-hyprland/.config/quickshell/components/ModulePopup.qml) :
- **Instanciation Paresseuse & Destroy-on-Close :** Les 11 popups de la barre ne sont pas maintenues en mémoire vive. Le composant `LazyPopup` n'instancie la surface `PopupWindow` et ses vues QML qu'à l'entrée du curseur (`hoverRequested`) ou au clic (`clickRequested`), et détruit immédiatement l'instance dès la fin de l'animation de fermeture (`onFullyClosed`).
- **Délai d'ouverture anti-spam (`140 ms`) :** Évite les instanciations et ouvertures accidentelles lors d'un simple balayage rapide du curseur.
- **Délai de fermeture fluide (`320 ms`) :** Permet la transition naturelle du curseur entre le bouton de la barre et la popup flottante sans rupture d'ancrage.
- **Animations cubiques fluides :** Fondu d'opacité `0.0 ➔ 1.0` en 150ms (`Easing.OutCubic`) et micro-zoom d'apparition `0.98 ➔ 1.0`.
- **Ouverture maintenue au clic :** Le clic épingle une popup ouverte au survol. Un second clic, Échap ou un clic hors de la barre et de la popup la ferme. Une seule popup reste ouverte à la fois.
- **Design ardoise :** Fond sombre légèrement dégradé, bordure neutre, coins de 18 px, marges de 16 px et typographie sans-serif. `PopupStyle.qml` reprend les tokens de `NotificationStyle.qml`. Les actions utilisent des icônes avec des noms accessibles, sans infobulles au survol.
- **Dimensions bornées :** Largeurs logiques de 220 à 300 px, réduites selon la largeur disponible ; hauteur limitée à l’écran avec défilement. Placement corrigé aux bords. Aucun flou supplémentaire n’est ajouté.
- **Données à la demande :** Le timer de débit de la popup réseau s’arrête dès la fermeture. L’IP est lue à l’ouverture puis toutes les 15 secondes pendant l’affichage, l’uptime une fois par minute.


## Dimensions des popups ardoise

| Popup | Dimensions logiques |
| --- | ---: |
| Réseau | 300 × 150 px (horizontal, 2:1) |
| Énergie | 220 px, hauteur selon le contenu |
| Application | 280 px, hauteur selon le contenu |
| Musique / Horloge | 300 px, hauteur selon le contenu |

Le [design validé A](floating-popups-design.md) et sa [maquette interactive](floating-popups-proposal.html) documentent les choix visuels. La barre conserve ses dimensions et sa palette propres.

Avec des marges internes de 12 px et des espacements resserrés, les six cartes horizontales héritent du même cadre `MetricPopup.qml`, dont les dimensions sont `PopupStyle.metricWidth` et `metricHeight`. Leur taille reste identique lorsque les détails sont dépliés ; le contenu défile si nécessaire. Sur un petit écran, les cinq cartes sont réduites avec le même facteur pour préserver le ratio horizontal. Le placement déplace le cadre sans changer séparément sa hauteur.

Le calendrier utilise une largeur calculée commune aux sept colonnes, y compris leurs en-têtes. Les jauges et pistes de curseurs des popups font 8 px d’épaisseur ; les icônes de batterie et de profil font 24 px. Les débits réseau affichent seulement leurs valeurs avec ↑/↓, et l’adresse locale reste visible sans dépliage.


## Topbar ardoise

Les commandes conservent leurs gestes : CPU/RAM vers btop au clic droit, réseau vers nmtui, volume vers pavucontrol, molettes de luminosité (3 %) et volume (5 %), commandes MPRIS, activation/fermeture des fenêtres, tray et DND. La popup musicale reste réservée au clic droit. L’ordre des modules et le masquage du lecteur ou de la batterie absents sont conservés.

Les hauteurs restent 24 px en 720p, 26 px en 1080p et 35 px en 1440p. Les boutons occupent 22 px à l’intérieur de cette surface. CPU/RAM disposent d’au moins 72 px et le réseau 90 px ; l’espace supplémentaire est repris au titre musical, selon le même budget horizontal cumulé. La zone des fenêtres n’a plus de plafond fixe : elle occupe tout l’espace libre (80 px restent réservés au titre actif) et défile à la molette au-delà, en ramenant toujours la fenêtre active dans la vue. Le titre actif conserve une largeur maximale de 350 px, sans recouvrir les modules, et conserve son texte complet comme nom accessible.

Les tokens globaux de `Theme.qml` ci-dessus restent disponibles pour les autres surfaces. Les couleurs propres à la barre sont dans `BarStyle.qml`. Voir [le design et les contrôles de validation](topbar-design.md).

Les lectures périodiques CPU, RAM, réseau et uptime sont asynchrones : les timers demandent une lecture, puis `FileView.onLoaded` traite les données. Aucun `blockAllReads` n’est utilisé pour ces métriques. La pochette MPRIS se charge en arrière-plan avec une taille demandée de 64 × 64. Pour mesurer les ralentissements en session réelle, voir le [guide de diagnostic](diagnostic-lags.md).

Depuis le 2026-10-07, les modules CPU, RAM, luminosité, batterie et son affichent leurs indicateurs sans popup. Les clics droits CPU/RAM (btop), le clic droit audio (pavucontrol), les molettes restent disponibles. Le calendrier et le réseau conservent leurs popups. Les lecteurs `FileView` de métriques doivent garder `preload: true` pour que `reload()` lance effectivement la lecture asynchrone.
