# 🚀 Lanceur d'Applications Quickshell (`hdg-quickshell-launcher`)

Documentation technique du Lanceur d'Applications natif en verre dépoli Obsidian Glass développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Fonctionnalités

Le lanceur d'applications réside dans `.config/quickshell/launcher/` et offre une interface moderne et réactive :
- **Design Obsidian Glass & Glacier Blue :** Fenêtre centrale occupant **33% de la largeur d'écran** (`Theme.relWidth(0.33)`), fond Obsidian Glass (`rgba(11, 15, 20, 0.85)`), fine bordure Glacier Blue (`rgba(93, 173, 226, 0.35)`) et coins arrondis à 20px.
- **Animation Style Apple :** Micro-zoom d'apparition élastique (`0.92 ➔ 1.0`) avec courbe de rebond `Easing.OutBack` façon macOS Spotlight / iOS Springboard (220ms).
- **Grille 5 Colonnes & Centrage Dynamique :** Hauteur de cellule de 140px avec grandes icônes de 52x52px. Lorsque la sélection comporte moins de 5 éléments, la rangée se recentre automatiquement.
- **Révélation des Noms au Survol/Sélection :** Les noms des applications sont masqués par défaut et apparaissent en fondu lors du focus clavier ou survol souris.
- **Tri Intelligent par Fréquence d'Utilisation (MRU) :** Suivi persistant des lancements dans `$XDG_STATE_HOME/quickshell/launcher_history.json`.
- **Cascade de Résolution d'Icônes Infaillible :** Moteur multi-niveaux supportant les chemins directs, noms minuscules, suppression de reverse-DNS `org.gnome.*`, dictionnaire d'alias et icône Nerd Font thématique contextuelle en cas d'absence de fichier image.

---

## 🏛️ 2. Arborescence du Module `launcher/`

```
.config/quickshell/launcher/
├── LauncherService.qml      # Singleton IPC (toggle, open, close) et visibilité
├── LauncherWindow.qml       # Fenêtre overlay 33%, grille 5 colonnes, tri MRU, animation Apple
└── qmldir                   # Déclaration de module
```

---

## ⌨️ 3. Contrôles & Navigation Clavier

| Touche / Action | Rôle |
|:---|:---|
| <kbd>SUPER</kbd> + <kbd>Espace</kbd> | Ouvrir / Basculer le lanceur d'applications |
| <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd> | Naviguer dans la grille 5 colonnes |
| <kbd>Tab</kbd> / <kbd>Maj</kbd> + <kbd>Tab</kbd> | Cycler parmi les applications filtrées |
| <kbd>Entrée</kbd> | Lancer l'application sélectionnée via `uwsm app --` |
| <kbd>Échap</kbd> ou **Clic extérieur** | Fermer le lanceur instantanément |

---

## 🔌 4. Interface IPC

```bash
quickshell ipc call launcher toggle
quickshell ipc call launcher open
quickshell ipc call launcher close
```
