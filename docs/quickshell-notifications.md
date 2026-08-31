# 🔔 Serveur de Notifications & Centre de Contrôle Quickshell (`hdg-quickshell-notifications`)

Documentation technique du sous-système de notifications D-Bus et du Centre de Contrôle modulaire développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Fonctionnalités

Le sous-système de notifications réside dans `.config/quickshell/notifications/` et remplace intégralement SwayNC :
- **Serveur D-Bus Natif :** Implémentation complète de la spécification standard `org.freedesktop.Notifications`.
- **Centre de Contrôle Inspiré d'Apple :** Positionné en **haut au milieu** de l'écran (centré horizontalement sur l'axe X, calé sous la barre d'état sur l'axe Y), avec fond assombri dismissible au clic (`backdrop`) ou via la touche <kbd>Échap</kbd>.
- **Design Obsidian Glass Haute Opacité (94%) :** Fond sombre (`rgba(11, 15, 20, 0.94)`), fine bordure Glacier Blue (`Theme.glassBorder`) et flou matériel Wayland (`qs-panel`).
- **Dimensions Fixes & Proportions Carrées :**
  - **Largeur standardisée :** 480 px (`Theme.notificationPanelWidth: 480`) garantissant un affichage parfaitement identique sur tous les ratios d'écran (1080p, 1440p, 4K, Ultrawide).
  - **Toggles tactiles rapides :** Pavés quasi carrés de 64 px de hauteur (Wi-Fi, Bluetooth, Micro, Audio) avec icônes agrandies (`Theme.fontSizeHeader`).
  - **Curseurs en capsule de verre :** Hauteur de 42 px avec pourcentages en direct et réglage instantané.
  - **Boutons d'action système :** Hauteur de 40 px (Verrouiller, Session).
  - **Bloc-notes persistant (Scratchpad) :** Zone de saisie étendue à 150 px.
  - **Liste d'historique des notifications :** Défilement fluide jusqu'à 360 px de hauteur.
- **Toasts OSD Éphémères :** Alertes visuelles animées de 380 px de large avec jauge de compte à rebours fluide à 60fps et pause au survol.
- **Lazy Loading & Destructibilité :** Instanciation à la demande par `Loader` dans `shell.qml` et destruction à la fermeture pour une consommation mémoire nulle hors utilisation.
- **Filtrage Anti-Spam :** Rejet immédiat des notifications fantômes sans résumé ni corps issues des mises à jour D-Bus.

---

## 🏛️ 2. Arborescence du Module `notifications/`

```
.config/quickshell/notifications/
├── NotificationService.qml      # Singleton D-Bus (NotificationServer), état DND, historique, IPC
├── NotificationToastWindow.qml  # Fenêtre de toasts flottants OSD avec jauge fluide 60fps
├── NotificationCenter.qml       # Conteneur haut-centré (480px) avec backdrop dismissible
├── qmldir                       # Déclaration de module
└── components/                  # Sous-composants modulaires à responsabilité unique
    ├── QuickSettings.qml        # Toggles 64px carrés (Wi-Fi, BT, Micro, Audio) & Actions 40px
    ├── VolumeBrightnessSliders.qml # Curseurs 42px en capsule (Volume, Luminosité)
    ├── NotificationList.qml     # Liste défilante (360px max), actions et état vide
    └── Scratchpad.qml           # Mini bloc-notes 150px persistant (scratchpad.txt)
```

---

## 🔧 3. Composants & Architecture

### 1. `NotificationService.qml` (Singleton D-Bus)
- **Instanciation D-Bus :** `Quickshell.Services.Notifications.NotificationServer` revendique `org.freedesktop.Notifications`.
- **Mode Ne Pas Déranger (DND) :** Filtre l'affichage des popups OSD tout en archivant les notifications dans l'historique.
- **Gestionnaire IPC (`target: "notifications"`) :**
  ```bash
  quickshell ipc call notifications toggle
  quickshell ipc call notifications toggleDnd
  quickshell ipc call notifications clear
  ```

### 2. `NotificationToastWindow.qml` (Toasts OSD)
- Surface Layer-Shell `Overlay` dans le coin supérieur droit (largeur 380 px).
- Progression d'expiration visuelle animée via `NumberAnimation` fluide à 60fps.
- Pause automatique du compte à rebours au survol de la souris.
- Rendu d'icône d'application via `IconImage` avec repli automatique sur la cloche.

### 3. `NotificationCenter.qml` & Sous-Composants
- **`QuickSettings.qml` :** 4 pavés tactiles 64px à grandes icônes et boutons Verrouiller / Session (40px).
- **`VolumeBrightnessSliders.qml` :** Curseurs horizontaux 42px en verre dépoli avec icônes intégrées et manipulation WirePlumber / brightnessctl.
- **`NotificationList.qml` :** Cartes de notifications avec boutons d'actions interactifs et suppression globale (`󰃢`).
- **`Scratchpad.qml` :** Bloc-notes 150px synchronisé automatiquement dans `$XDG_STATE_HOME/quickshell/scratchpad.txt` avec raccourci de copie instantanée dans le presse-papier (`wl-copy`).
