```
██╗  ██╗██████╗  ██████╗       ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔════╝       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║██║  ██║██║  ███╗█████╗███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║██║  ██║██║   ██║╚════╝██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║██████╔╝╚██████╔╝      ██║  ██║   ██║   ██║     ███████╗██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
```

Ce dépôt contient mes fichiers de configuration personnels pour **Hyprland** et ses composants associés. La configuration a été modernisée selon les standards récents, avec notamment la migration complète de la partie **hypr/** vers **Lua** et le support de **UWSM**.

---

## 📸 Aperçu (Showcase)

![Configuration Vide](/media/empty.png)

![Configuration Active](/media/full.png)

![Écran de déconnexion](/media/wlogout.png)

---

## 📁 Structure des Dossiers

La configuration est organisée comme suit :

```
.config
├── hypr
│   ├── hyprland.lua                # Configuration principale (Lua)
│   ├── binds.lua                   # Raccourcis et dispatchers (Lua)
│   ├── programs.lua                # Applications par défaut et autostart UWSM
│   ├── hypridle.conf               # Gestionnaire d'inactivité (Idle)
│   ├── hyprlock.conf               # Écran de verrouillage (Lock screen)
│   ├── hyprpaper.conf              # Gestionnaire de fond d'écran
│   ├── picture/                    # Fonds d'écran
│   └── scripts/                    # Scripts utilitaires d'intégration
│       ├── battery-level.sh        # Notification de batterie faible
│       ├── check-dependencies.sh   # Validation des dépendances système
│       ├── gesture.sh              # Traduction des gestes tactiles vers Lua
│       └── monitor.sh              # Gestion dynamique des écrans externes
├── rofi
│   ├── config.rasi                 # Configuration globale de Rofi
│   └── themes/
│       └── theme.rasi              # Thème graphique Rofi
├── swaync
│   ├── config.json                 # Configuration du centre de notifications
│   └── style.css                   # Style personnalisé SwayNC
├── waybar
│   ├── config                      # Structure et inclusion des modules
│   ├── style.css                   # Feuille de style Waybar
│   └── modules/                    # Fichiers de configuration des modules
│       ├── backlight.jsonc
│       ├── battery.jsonc
│       ├── clock.jsonc
│       ├── cpu.jsonc
│       ├── custom-launcher.jsonc
│       ├── custom-power.jsonc
│       ├── custom-swaync.jsonc
│       ├── hyprland-window.jsonc
│       ├── memory.jsonc
│       ├── mpris.jsonc
│       ├── network.jsonc
│       ├── pulseaudio.jsonc
│       ├── wlr-taskbar.jsonc
│       └── workspace.jsonc
└── wlogout
    ├── layout                      # Disposition et actions des boutons
    ├── style.css                   # Feuille de style Wlogout
    └── icons/                      # Icônes SVG associées
```

---

## 🔍 Audit de la Configuration (Juin 2026)

Suite à la migration réussie de la partie **hypr/** vers Lua, une analyse des autres composants de la configuration a été menée pour identifier les incohérences et opportunités d'amélioration.

### 1. Hyprland (Lua) & UWSM 🟢
* **Statut** : Conforme et moderne.
* **Observations** :
  * Bonne séparation entre les raccourcis (`binds.lua`), les variables (`programs.lua`), et l'apparence (`hyprland.lua`).
  * Les binaires et services complémentaires sont convenablement encapsulés via `uwsm app --`.

### 2. Waybar 🟡
* **Points d'attention** :
  * **Incompatibilité de défilement (`workspace.jsonc`)** : Les actions `on-scroll-up` et `on-scroll-down` utilisent la commande legacy `hyprctl dispatch workspace e±1`. Cette syntaxe contourne ou peut entrer en conflit avec les dispatchers du provider Lua. Elles doivent appeler la commande compatible Lua : `hyprctl dispatch 'hl.dsp.focus({ workspace = "e±1" })'`.
  * **Chemin cassé (`memory.jsonc`)** : L'action au clic droit tente d'exécuter `kitty -c ~/.config/dotfiles/kitty/kitty.conf ...`. Ce dossier `dotfiles` n'existe pas dans le dépôt (les fichiers étant placés directement à la racine de `.config/`), ce qui provoque l'échec de la commande.
* **Recommandation** : Mettre à jour les commandes pour utiliser les dispatchers Lua et généraliser l'appel à Kitty.

### 3. Rofi 🔴
* **Point d'attention** :
  * **Thème introuvable (`config.rasi`)** : La directive `@theme` pointe vers `"~/.config/rofi/themes/catppuccin-macchiato.rasi"`, un fichier qui n'existe pas dans le dépôt. Le seul thème réellement présent et personnalisé est `themes/theme.rasi`.
* **Recommandation** : Pointer explicitement vers le thème local valide.

### 4. SwayNC 🟡
* **Point d'attention** :
  * **Dépendance matérielle (`config.json`)** : Le module `backlight` cible explicitement `"device": "amdgpu_bl1"`. Cette directive casse le widget sur les machines Intel (qui requièrent généralement `intel_backlight`) ou d'autres configurations AMD.
* **Recommandation** : Retirer la clé `"device"` pour laisser SwayNC auto-détecter l'interface de rétroéclairage ou documenter cette spécificité matérielle.

### 5. Wlogout 🟡
* **Point d'attention** :
  * **Méthode de déconnexion (`layout`)** : L'action liée au bouton de déconnexion utilise `loginctl terminate-user $USER`. Dans un environnement géré par UWSM, il est recommandé de fermer proprement la session via la commande `uwsm stop`.
* **Recommandation** : Remplacer l'action par la commande native UWSM pour un arrêt propre.

---

## 🛠️ Plan de Modernisation

Voici les modifications préconisées pour aligner l'ensemble de la configuration sur les nouveaux standards :

### A. Correction Rofi
Dans [.config/rofi/config.rasi](file:///.config/rofi/config.rasi#L16) :
```diff
- @theme "~/.config/rofi/themes/catppuccin-macchiato.rasi"
+ @theme "~/.config/rofi/themes/theme.rasi"
```

### B. Correction Waybar
Dans [.config/waybar/modules/workspace.jsonc](file:///.config/waybar/modules/workspace.jsonc#L8-L9) :
```diff
- 		"on-scroll-up": "hyprctl dispatch workspace e+1",
- 		"on-scroll-down": "hyprctl dispatch workspace e-1",
+ 		"on-scroll-up": "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'",
+ 		"on-scroll-down": "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'",
```

Dans [.config/waybar/modules/memory.jsonc](file:///.config/waybar/modules/memory.jsonc#L8) :
```diff
- 		"on-click-right": "kitty -c ~/.config/dotfiles/kitty/kitty.conf --title btop sh -c 'btop'"
+ 		"on-click-right": "kitty --title btop -e btop"
```

### C. Correction SwayNC
Dans [.config/swaync/config.json](file:///.config/swaync/config.json#L83) :
```diff
-       "device": "amdgpu_bl1"
+       // Retirer cette ligne pour activer l'auto-détection du GPU
```

### D. Correction Wlogout
Dans [.config/wlogout/layout](file:///.config/wlogout/layout#L33) :
```diff
-     "action" : "loginctl terminate-user $USER",
+     "action" : "uwsm stop",
```

---

## 📦 Dépendances requises

Pour garantir le bon fonctionnement de tous les modules :

- **Hyprland** (>= 0.55) avec support Lua
- **UWSM** (Wayland Session Manager)
- **Waybar** (Barre d'état)
- **Rofi** (Lanceur d'applications)
- **SwayNC** (Centre de notifications)
- **Wlogout** (Menu de déconnexion)
- **kitty** (Émulateur de terminal)
- **brightnessctl** & **playerctl** (Contrôles multimédia)

---

## 🚀 Installation

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/hdg-zero/hdg-hyprland.git
   ```
2. Créer des liens symboliques (plutôt qu'une simple copie) depuis le dépôt vers `~/.config/` pour maintenir vos modifications synchronisées avec Git.
3. Recharger la configuration :
   ```bash
   hyprctl reload
   ```

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.