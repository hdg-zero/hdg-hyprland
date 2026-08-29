# 🚪 Menu de Session Quickshell (`hdg-quickshell-session`)

Documentation technique du Menu de Session plein écran natif (Power Menu) développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Architecture

Le module de session réside dans `.config/quickshell/session/` et remplace intégralement `wlogout` :
- **Zéro dépendance GTK :** Interface plein écran native Wayland en verre dépoli Obsidian Glass.
- **Focus Exclusif Instantané :** `WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive` capture immédiatement toutes les touches dès l'ouverture.
- **Raccourcis Directs :** Une touche unique par action pour une efficacité maximale.

---

## 🏛️ 2. Arborescence du Module `session/`

```
.config/quickshell/session/
├── SessionService.qml       # Singleton d'état, helper d'actions système et IpcHandler
├── SessionWindow.qml        # Fenêtre plein écran Obsidian Glass avec 6 cartes d'actions
└── qmldir                   # Déclaration de module
```

---

## ⌨️ 3. Cartes d'Actions & Raccourcis Clavier

| Touche | Action | Commande Exécutée |
|:---|:---|:---|
| <kbd>L</kbd> | Verrouiller | `uwsm app -- hyprlock` |
| <kbd>U</kbd> | Veille | `loginctl lock-session && systemctl suspend` |
| <kbd>E</kbd> | Déconnexion | `uwsm stop` |
| <kbd>H</kbd> | Hiberner | `systemctl hibernate` |
| <kbd>R</kbd> | Redémarrer | `systemctl reboot` |
| <kbd>S</kbd> | Éteindre | `systemctl poweroff` |
| <kbd>Échap</kbd> | Annuler / Fermer | `SessionService.close()` |

---

## 🔌 4. Interface IPC

Le menu peut être contrôlé via l'outil IPC de Quickshell et les raccourcis Hyprland (<kbd>SUPER</kbd> + <kbd>M</kbd>) :

```bash
quickshell ipc call session toggle
quickshell ipc call session open
quickshell ipc call session close
```
