# 🚀 Lanceur d'Applications Quickshell (`hdg-quickshell-launcher`)

Documentation technique du Lanceur d'Applications natif en verre dépoli Obsidian Glass développé sous **[Quickshell](https://quickshell.outfoxxed.me/) v0.3.1+** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Vision & Fonctionnalités

Le lanceur d'applications réside dans `.config/quickshell/launcher/` et offre une interface moderne, fluide et polyvalente :
- **Design Obsidian Glass & Glacier Blue :** Fenêtre centrale occupant **33% de la largeur d'écran** (`Theme.relWidth(0.33)`), fond Obsidian Glass (`rgba(11, 15, 20, 0.85)`), fine bordure Glacier Blue (`rgba(93, 173, 226, 0.35)`) et coins arrondis à 20px.
- **Animation Style Apple :** Micro-zoom d'apparition élastique (`0.92 ➔ 1.0`) avec courbe de rebond `Easing.OutBack` façon macOS Spotlight / iOS Springboard (220ms).
- **Mode Commande Terminal Immédiat (`>`) :** Saisie du caractère `>` au début de la recherche déclenchant dynamiquement le mode exécution Shell. L'interface bascule sur une carte terminal épurée avec prévisualisation du prompt `$ <commande>`, badge <kbd>Entrée</kbd> et exécution directe dans Kitty sous UWSM (`uwsm app -- kitty sh -c "<cmd>; exec ${SHELL:-bash}"`) conservant le shell interactif.
- **Historique Intelligent Top 5 des Commandes :** Suivi persistant du nombre d'exécutions dans `$XDG_STATE_HOME/quickshell/cmd_history.json` via `FileView`, tri dynamique par fréquence d'utilisation, filtrage en direct avec la frappe et navigation clavier immédiate (<kbd>↑</kbd>/<kbd>↓</kbd>).
- **Grille 5 Colonnes & Centrage Dynamique :** Hauteur de cellule de 140px avec grandes icônes de 52x52px. Lorsque la sélection comporte moins de 5 éléments, la rangée se recentre automatiquement.
- **Révélation des Noms au Survol/Sélection :** Les noms des applications sont masqués par défaut et apparaissent en fondu lors du focus clavier ou survol souris.
- **Tri Intelligent par Fréquence d'Utilisation (MRU) :** Suivi persistant des lancements d'applications dans `$XDG_STATE_HOME/quickshell/launcher_history.json`.
- **Lazy Loading & Destructibilité :** La fenêtre du lanceur est instanciée à la demande via un `Loader` dans `shell.qml` et détruite après l'animation de fermeture, garantissant zéro consommation mémoire en arrière-plan.
- **Cascade de Résolution d'Icônes Infaillible :** Moteur multi-niveaux supportant les chemins directs, noms minuscules, suppression de reverse-DNS `org.gnome.*`, dictionnaire d'alias mémoïsé (`iconCache`) et icône Nerd Font thématique contextuelle.

---

## 🏛️ 2. Arborescence du Module `launcher/`

```
.config/quickshell/launcher/
├── LauncherService.qml      # Singleton IPC (toggle, open, close) et visibilité
├── LauncherWindow.qml       # Fenêtre overlay 33%, grille 5 colonnes, mode commande '>', tri MRU
└── qmldir                   # Déclaration de module
```

---

## ⌨️ 3. Contrôles & Navigation Clavier

| Touche / Action | Rôle |
|:---|:---|
| <kbd>SUPER</kbd> + <kbd>Espace</kbd> | Ouvrir / Basculer le lanceur d'applications |
| <kbd>></kbd> + `<commande>` | Passer en mode exécution de commande terminal |
| <kbd>↑</kbd> <kbd>↓</kbd> <kbd>←</kbd> <kbd>→</kbd> | Naviguer dans la grille d'applications ou dans le Top 5 des commandes |
| <kbd>Tab</kbd> / <kbd>Maj</kbd> + <kbd>Tab</kbd> | Cycler parmi les applications filtrées |
| <kbd>Entrée</kbd> | Lancer l'application ou exécuter la commande terminal dans Kitty |
| <kbd>Échap</kbd> ou **Clic extérieur** | Fermer le lanceur instantanément |

---

## 🔌 4. Interface IPC

```bash
quickshell ipc call launcher toggle
quickshell ipc call launcher open
quickshell ipc call launcher close
```
