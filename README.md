```
██╗  ██╗██████╗  ██████╗       ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔════╝       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║██║  ██║██║  ███╗█████╗███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║██║  ██║██║   ██║╚════╝██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║██████╔╝╚██████╔╝      ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
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

## 🔍 État de la Configuration & Modernisation (Juin 2026) 🟢

L'ensemble de la configuration a été audité et modernisé pour respecter les standards actuels d'un environnement **Hyprland** (Lua) géré sous **UWSM**.

### 1. Hyprland (Lua) & UWSM 🟢
* **Statut** : Conforme et moderne.
* **Architecture** : Séparation complète de la logique (`hyprland.lua`), des raccourcis (`binds.lua`), et des autostarts/variables (`programs.lua`). L'autostart et les lancements d'applications se font via `uwsm app --`.

### 2. Waybar 🟢
* **Correctifs appliqués** :
  * **Défilement des workspaces** : Adapté pour appeler le dispatcher Lua `hl.dsp.focus` via `hyprctl dispatch 'hl.dsp.focus({ workspace = "e±1" })'` à la place de la syntaxe native obsolète.
  * **Clic droit sur la RAM** : Correction du raccourci pour lancer `btop` directement dans `kitty` sans référencer un fichier de configuration inexistant.

### 3. Rofi 🟢
* **Correctifs appliqués** :
  * **Thème graphique** : Correction de la liaison du thème dans `config.rasi` pour cibler correctement le thème personnalisé local `themes/theme.rasi` au lieu d'une dépendance manquante.

### 4. SwayNC 🟢
* **Correctifs appliqués** :
  * **Luminosité** : Suppression de la ligne hardware codée en dur `"device": "amdgpu_bl1"` pour permettre la détection automatique et assurer la portabilité de la barre de notifications sur n'importe quelle machine (Intel, AMD, Nvidia).

### 5. Wlogout 🟢
* **Correctifs appliqués** :
  * **Déconnexion propre** : Remplacement de l'action agressive `loginctl terminate-user $USER` par la commande native d'arrêt de session `uwsm stop`.
  * **Icônes** : Ajout et suivi de l'icône manquante `veille.svg` pour le bouton de mise en veille.

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