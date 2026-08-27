```
██╗  ██╗██████╗  ██████╗       ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔════╝       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║██║  ██║██║  ███╗█████╗███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║██║  ██║██║   ██║╚════╝██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║██████╔╝╚██████╔╝      ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝
```

Ce dépôt contient mes fichiers de configuration personnels pour **Hyprland** et ses composants associés. La configuration a été auditée et modernisée selon les standards **Hyprland 0.56+** (Lua) sous **UWSM**, avec une barre d'état interactive nouvelle génération développée sous **Quickshell v0.3.1**.

---

## 📁 Structure des Dossiers

La configuration est organisée comme suit :

```
.
├── CHANGELOG.md                    # Journal des modifications (Keep a Changelog)
├── LICENSE                         # Licence MIT
├── README.md                       # Documentation principale
├── docs/                           # Documentations techniques
│   └── quickshell-bar.md           # Architecture & guide complet de la barre Quickshell
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
    │   └── kitty.conf              # Émulateur de terminal Kitty
    ├── quickshell                  # Barre d'état réactive, popups & notifications (Quickshell 0.3.1)
    │   ├── shell.qml               # Point d'entrée ShellRoot (multi-écrans)
    │   ├── theme/                  # Tokens visuels (Obsidian Glass & Glacier Blue)
    │   ├── components/             # Composants d'interface (GlassCard, PillButton, ModulePopup)
    │   ├── bar/                    # Modules de la barre et fenêtres popups
    │   └── notifications/          # Serveur de notifications natif D-Bus & Centre de Contrôle
    ├── rofi
    │   ├── config.rasi             # Configuration globale de Rofi
    │   └── themes/
    │       └── theme.rasi          # Thème graphique Rofi
    ├── wlogout
    │   ├── layout                  # Disposition (verrouillage sécurisé avant suspend)
    │   ├── style.css               # Feuille de style Wlogout
    │   └── icons/                  # Icônes SVG associées
    └── starship.toml               # Configuration du prompt de terminal Starship
```

---

## 🔍 État de la Configuration & Modernisation 🟢

L'ensemble de la configuration a été audité et mis à niveau pour **Hyprland 0.56+** et **Quickshell 0.3.1+**.

### 1. Barre d'État & Centre de Contrôle Quickshell Nouvelle Génération 🟢
*(Voir la [Documentation technique détaillée](docs/quickshell-bar.md))*
* **Design "Obsidian Glass & Glacier Blue"** : Effet de verre fumé translucide sombre avec reflets glassmorphic, bordures subtiles et accents bleu glacier.
* **100% Dimensionnement Relatif & Proportionnel** : Zéro pixel codé en dur, chaque élément (modules, barres, curseurs, popups, panneau de notifications) s'adapte automatiquement à toutes les résolutions (FHD, QHD, 4K, multi-écrans).
* **Fenêtres flottantes interactives (Popups)** : Chaque module dispose d'une fenêtre détaillée ouverte au survol intelligent (avec temporisation anti-scintillement) ou au clic :
  - **CPU & RAM** : Charge en direct, détail par cœur, température, load average, répartition RAM/Swap, Top 5 des processus les plus gourmands et raccourci `btop`.
  - **Réseau** : SSID/Filaire, IPv4, passerelle, débits temps réel (↓/↑), totaux session et accès rapide à `nm-connection-editor` / `nmtui`.
  - **Musique MPRIS** : Pochette grand format HD centrée, métadonnées épurées et contrôles multimédias 100% relatifs.
  - **Barre des tâches & AppPopup** : Aperçu riche au survol de chaque icône d'application (titre de la fenêtre, workspace, statut plein écran/flottant, bouton focus et fermeture rapide).
  - **Contrôles matériel** : Sliders interactifs pour le volume audio PipeWire (0-150%), luminosité écran et profils d'alimentation UPower (**Éco**, **Équilibré**, **Max**).
  - **Horloge & Calendrier** : Vue calendaire complète du mois en français avec jour actif surligné et uptime système.
* **Serveur de Notifications D-Bus & Centre de Contrôle Natif** :
  - **Démon natif D-Bus** : Implémente la spécification standard `org.freedesktop.Notifications` sous Quickshell sans nécessiter de démon tiers (SwayNC supprimé).
  - **Centre de Contrôle inspiré d'Apple macOS/iOS** : Toggles tactiles compacts sans texte superflu (Wi-Fi, Bluetooth, Mute Micro, Mute Audio), curseurs de volume et luminosité en capsules de verre, raccourcis de session (`hyprlock`, `wlogout`), mode Ne Pas Déranger (DND) et historique complet.
  - **Toasts OSD éphémères** : Alertes flottantes animées avec barre de compte à rebours d'expiration et pause au survol.
* **Sobriété énergétique & performances** : Empreinte RAM minimale (< 25 Mo), lazy-loading des processus système (0% CPU au repos), zéro polling et exécutions asynchrones non-bloquantes via `Quickshell.execDetached`.

### 2. Gestion des Écrans (Monitors 0.56) 🟢
* **Inventaire matériel complet** : Utilisation de `hl.get_monitors({ all = true })` pour inclure toutes les sorties (y compris désactivées).
* **Écran externe prioritaire** : Lors du branchement d'un écran externe, l'affichage externe est automatiquement activé et priorisé.
* **Sécurité Capot** : Fallback `SAFETY_FALLBACK` garantissant que l'écran interne reste actif si le capot est fermé sans écran externe connecté.

### 3. Veille et Verrouillage (Lock/Suspend) 🟢
* **Attente du verrouillage** : Ajout de `inhibit_sleep = true` dans `hypridle.conf` et mise à jour de Wlogout (`loginctl lock-session && systemctl suspend`) pour éliminer tout risque de session visible au réveil.

### 4. Contrôle des Dépendances & Nettoyage 🟢
* **Script de vérification** : `check-dependencies.sh` distingue les dépendances obligatoires des optionnelles et retourne un code d'erreur non-nul (`exit 1`) en cas de prérequis manquant.
* **Suppression des composants obsolètes** : Suppression intégrale de `waybar`, `monitor.sh` et `gesture.sh` pour maintenir un environnement propre et sans redondance.

---

## 📦 Dépendances requises

Pour vérifier l'état des dépendances sur votre système :
```bash
~/.config/hypr/scripts/check-dependencies.sh
```

- **Hyprland** (>= 0.56.0) avec support Lua
- **UWSM** (Wayland Session Manager)
- **Quickshell** (>= 0.3.1)
- **hypridle** & **hyprlock**
- **Rofi**, **Wlogout**, **kitty**
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

   for dir in hypr kitty quickshell rofi wlogout; do
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
