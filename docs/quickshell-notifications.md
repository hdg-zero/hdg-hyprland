# 🔔 Serveur de Notifications & Centre de Contrôle Quickshell (`hdg-quickshell-notifications`)

Documentation technique du sous-système de notifications D-Bus et du Centre de Contrôle modulaire développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Fonctionnalités

Le sous-système de notifications réside dans `.config/quickshell/notifications/` et remplace intégralement SwayNC :
- **Serveur D-Bus Natif :** Implémentation complète de la spécification standard `org.freedesktop.Notifications`.
- **Centre de Contrôle Inspiré d'Apple :** Toggles tactiles sans texte superflu, curseurs en capsule de verre, bloc-notes persistant et historique des notifications.
- **Toasts OSD Éphémères :** Alertes visuelles animées avec jauge de compte à rebours fluide à 60fps et pause au survol.
- **Filtrage Anti-Spam :** Rejet immédiat des notifications fantômes sans résumé ni corps issues des mises à jour D-Bus.

---

## 🏛️ 2. Arborescence du Module `notifications/`

```
.config/quickshell/notifications/
├── NotificationService.qml      # Singleton D-Bus (NotificationServer), état DND, historique, IPC
├── NotificationToastWindow.qml  # Fenêtre de toasts flottants OSD avec jauge fluide 60fps
├── NotificationCenter.qml       # Conteneur principal du Centre de Contrôle
├── qmldir                       # Déclaration de module
└── components/                  # Sous-composants modulaires à responsabilité unique
    ├── QuickSettings.qml        # Toggles Wi-Fi, Bluetooth, Micro, Audio, Lock, Session
    ├── VolumeBrightnessSliders.qml # Curseurs horizontaux de volume et luminosité en capsule
    ├── NotificationList.qml     # Liste des notifications, actions et état vide
    └── Scratchpad.qml           # Mini bloc-notes persistant (scratchpad.txt)
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
- Surface Layer-Shell `Overlay` dans le coin supérieur droit.
- Progression d'expiration visuelle animée via `NumberAnimation` fluide à 60fps.
- Pause automatique du compte à rebours au survol de la souris.

### 3. `NotificationCenter.qml` & Sous-Composants
- **`QuickSettings.qml` :** Pavés tactiles compacts à grandes icônes (Wi-Fi, Bluetooth, Mute Micro, Mute Audio) et raccourcis Verrouiller / Session.
- **`VolumeBrightnessSliders.qml` :** Curseurs horizontaux en verre dépoli avec icônes intégrées et pourcentages en direct.
- **`NotificationList.qml` :** Cartes de notifications avec boutons d'actions interactifs et suppression globale (`󰃢`).
- **`Scratchpad.qml` :** Bloc-notes synchronisé automatiquement dans `$XDG_STATE_HOME/quickshell/scratchpad.txt` avec raccourci de copie instantanée dans le presse-papier (`wl-copy`).
