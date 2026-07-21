```
██╗  ██╗██████╗  ██████╗       ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔════╝       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║██║  ██║██║  ███╗█████╗███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║██║  ██║██║   ██║╚════╝██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║██████╔╝╚██████╔╝      ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
```

Ce dépôt contient mes fichiers de configuration personnels pour **Hyprland** et ses composants associés. La configuration a été auditée et migrée selon les standards **Hyprland 0.56+** (Lua) sous **UWSM**.

---

## 📁 Structure des Dossiers

La configuration est organisée comme suit :

```
.
├── CHANGELOG.md                    # Journal des modifications (Keep a Changelog)
├── LICENSE                         # Licence MIT
├── README.md                       # Documentation principale
└── .config
    ├── hypr
    │   ├── hyprland.lua            # Configuration principale (Lua)
    │   ├── binds.lua               # Raccourcis et dispatchers (Lua)
    │   ├── monitors.lua            # Machine à états de gestion dynamique des écrans (Lua 0.56)
    │   ├── programs.lua            # Applications par défaut et autostart
    │   ├── hypridle.conf           # Gestionnaire d'inactivité sécurisé (inhibit_sleep)
    │   ├── hyprlock.conf           # Écran de verrouillage (Lock screen)
    │   ├── hyprpaper.conf          # Gestionnaire de fond d'écran
    │   ├── picture/                # Fonds d'écran
    │   ├── profiles/               # Profils matériels d'affichage
    │   │   └── default.lua         # Profil d'écran interne/externe par défaut
    │   └── scripts/                # Scripts utilitaires
    │       ├── battery-level.sh    # Notification de batterie faible
    │       └── check-dependencies.sh # Validation automatique des dépendances (exit code)
    ├── kitty
    │   └── kitty.conf              # Emulateur de terminal Kitty
    ├── rofi
    │   ├── config.rasi             # Configuration globale de Rofi
    │   └── themes/
    │       └── theme.rasi          # Thème graphique Rofi
    ├── swaync
    │   ├── config.json             # Configuration SwayNC (détection auto backlight & POSIX)
    │   └── style.css               # Style personnalisé SwayNC
    ├── waybar
    │   ├── config                  # Structure et inclusion des modules
    │   ├── style.css               # Feuille de style Waybar
    │   └── modules/                # Modules JSONC (battery, memory, network, etc.)
    ├── wlogout
    │   ├── layout                  # Disposition (verrouillage sécurisé avant suspend)
    │   ├── style.css               # Feuille de style Wlogout
    │   └── icons/                  # Icônes SVG associées
    └── starship.toml               # Configuration du prompt de terminal Starship
```

---

## 🔍 État de la Configuration & Modernisation (Juillet 2026) 🟢

L'ensemble de la configuration a été audité et mis à niveau pour la version **Hyprland 0.56**.

### 1. Gestion des Écrans (Monitors 0.56) 🟢
* **Inventaire matériel complet** : Utilisation de `hl.get_monitors({ all = true })` pour inclure toutes les sorties (y compris désactivées).
* **Écran externe prioritaire** : Lors du branchement d'un écran externe, l'affichage externe est automatiquement activé et priorisé.
* **Sécurité Capot** : Fallback `SAFETY_FALLBACK` garantissant que l'écran interne reste actif si le capot est fermé sans écran externe connecté.

### 2. Veille et Verrouillage (Lock/Suspend) 🟢
* **Attente du verrouillage** : Ajout de `inhibit_sleep = true` dans `hypridle.conf` et mise à jour de Wlogout (`loginctl lock-session && systemctl suspend`) pour éliminer tout risque de session visible au réveil.

### 3. Contrôle des Dépendances & Nettoyage 🟢
* **Script de vérification** : `check-dependencies.sh` distingue les dépendances obligatoires des optionnelles et retourne un code d'erreur non-nul (`exit 1`) en cas de prérequis manquant.
* **Suppression des scripts obsolètes** : `monitor.sh` et `gesture.sh` ont été supprimés afin d'assurer que `monitors.lua` reste l'unique source de vérité.

---

## 📦 Dépendances requises

Pour vérifier l'état des dépendances sur votre système :
```bash
~/.config/hypr/scripts/check-dependencies.sh
```

- **Hyprland** (>= 0.56.0) avec support Lua
- **UWSM** (Wayland Session Manager)
- **hypridle** & **hyprlock**
- **Waybar**, **Rofi**, **SwayNC**, **Wlogout**, **kitty**
- **brightnessctl**, **playerctl**, **wpctl**

---

## 🚀 Installation

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/hdg-zero/hdg-hyprland.git
   cd hdg-hyprland
   ```
2. Tester les dépendances :
   ```bash
   .config/hypr/scripts/check-dependencies.sh
   ```
3. Créer les liens symboliques vers `~/.config/` :
   ```bash
   REPO_PATH="$(pwd)"

   for dir in hypr kitty rofi swaync waybar wlogout; do
     if [ -e "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
       mv "$HOME/.config/$dir" "$HOME/.config/${dir}.bak"
     fi
     ln -sf "$REPO_PATH/.config/$dir" "$HOME/.config/$dir"
   done

   for file in starship.toml; do
     if [ -f "$HOME/.config/$file" ] && [ ! -L "$HOME/.config/$file" ]; then
       mv "$HOME/.config/$file" "$HOME/.config/${file}.bak"
     fi
     ln -sf "$REPO_PATH/.config/$file" "$HOME/.config/$file"
   done
   ```
4. Recharger la configuration :
   ```bash
   hyprctl reload
   ```

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.