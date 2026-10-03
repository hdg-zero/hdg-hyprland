# 🐚 Configuration Shell Bash (`.bashrc`)

Documentation technique de la configuration du shell interactif **Bash** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Rôle & Périmètre

Le fichier `.bashrc` situé à la racine du dépôt centralise les réglages du shell utilisateur interactif :
- **Portabilité & Zéro Chemin en Dur :** Utilisation stricte des variables d'environnement (`$HOME`, `$USER`, `$WAYLAND_DISPLAY`) garantissant un fonctionnement immédiat sur n'importe quel environnement.
- **Historique Persistant & Temps Réel :** Historique illimité (`HISTSIZE=-1`), élimination des doublons (`ignoredups:erasedups`), mode ajout (`histappend`) et écriture/relecture instantanée après chaque commande (`PROMPT_COMMAND`).
- **Prompt Moderne & Ergonomique :** Initialisation sécurisée du prompt universel [Starship](file:///Projets/github/hdg-hyprland/.config/starship.toml).
- **Outillage CLI Moderne :** Remplacement transparent des commandes standards par leurs équivalents Rust/modernes (`eza`, `bat`, `fd`, `rg`), raccourcis d'affichage (`lumi`), de gestion réseau (`wifi-on`, `wifi-off`, `wifi-config`) et utilitaires (`compress-pdf`, `convert`).
- **Résilience Matérielle (`fix-bt`) :** Raccourci dédié de réinitialisation bas-niveau du contrôleur Bluetooth en cas de plantage matériel ou de bug de sortie de veille.
- **Binaire Utilisateur & Outils IA :** Enrichissement du `$PATH` pour inclure `$HOME/.local/bin` et `$HOME/.lmstudio/bin` (LM Studio CLI).
- **Intégration Graphique Wayland (XDG Desktop Portal) :** Détection d'affichage Wayland (`$WAYLAND_DISPLAY`) et lancement automatique non-bloquant de `/usr/lib/xdg-desktop-portal-gtk` pour garantir le bon fonctionnement des sélecteurs de fichiers GTK.

---

## 🏛️ 2. Structure & Contenu

```bash
# shellcheck shell=bash
#
# ~/.bashrc
#

umask 0002

# Démarrage automatique du portail GTK pour les applications Wayland (sélecteurs de fichiers)
if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -x /usr/lib/xdg-desktop-portal-gtk ] && ! pgrep -u "$USER" -f "/usr/lib/xdg-desktop-portal-[g]tk" >/dev/null 2>&1; then
  /usr/lib/xdg-desktop-portal-gtk -r >/dev/null 2>&1 &
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# BASH HISTORY
export HISTSIZE=-1
export HISTFILESIZE=-1

export HISTCONTROL=ignoredups:erasedups # ignore les doublons
shopt -s histappend			# ajoute au lieu d'ecraser
export PROMPT_COMMAND="history -a;history -c; history -r; ${PROMPT_COMMAND:-}" # sauvegarde en temps reel

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# ALIAS
alias lumi="brightnessctl s "

alias wifi-off="nmcli radio wifi off"
alias wifi-on="nmcli radio wifi on"
alias wifi-config="nmtui"

alias ls="eza --icons=always"
alias tree="eza -TL"

alias convert="magick"

alias compress-pdf="gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf"

alias cat="bat"
alias find="fd"
alias grep="rg"

# Réinitialise le pilote btusb (noyau) et relance bluetoothd en cas de gel matériel
# ou de plantage du contrôleur Bluetooth au réveil (suspend/resume).
alias fix-bt='sudo modprobe -r btusb && sudo modprobe btusb && sudo systemctl restart bluetooth'

# Added by LM Studio CLI (lms) & Local user binaries
export PATH="$PATH:$HOME/.local/bin:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

alias ll="ls -lh"
```

---

## 🔧 3. Focus Technique : Diagnostic & Résolution Bluetooth (`fix-bt`)

### Problématique
Sur les chipsets Bluetooth Intel, Realtek ou MediaTek sous Linux, la sortie de veille (`suspend/resume`) ou la gestion agressive d'économie d'énergie USB (`autosuspend`) peut geler l'interface physique ou corrompre le firmware résident. Dans cet état, une simple relance du service utilisateur (`systemctl restart bluetooth`) redémarre le démon `bluetoothd` dans le vide sans rétablir la communication avec le contrôleur.

### Mécanisme du Correctif
L'alias `fix-bt` opère une réinitialisation étagée à double niveau :
1. **Couche Noyau / Matériel (`sudo modprobe -r btusb && sudo modprobe btusb`) :**
   - Décharge puis recharge le pilote de bus Bluetooth du noyau Linux.
   - Force un reset matériel du bus USB équivalent à un débranchement physique de la puce.
   - Recharge le firmware dans le contrôleur et réinstancie le nœud d'interface `hci0`.
2. **Couche Démon Système (`sudo systemctl restart bluetooth`) :**
   - Redémarre proprement le démon `bluetoothd` au-dessus de l'interface matérielle fraîchement réinitialisée.

---

## 🔗 4. Déploiement & Création du Lien Symbolique

Pour lier la configuration du dépôt à votre répertoire personnel `$HOME` :

### Commande Rapide Directe

```bash
ln -sf /Projets/github/hdg-hyprland/.bashrc "$HOME/.bashrc"
```

### Procédure Complète Sécurisée (avec sauvegarde)

```bash
REPO_PATH="$(pwd)"

# Sauvegarde de l'ancien .bashrc s'il ne s'agit pas déjà d'un lien symbolique
if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
  mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

# Création du lien symbolique
ln -sf "$REPO_PATH/.bashrc" "$HOME/.bashrc"
```

Pour appliquer immédiatement les modifications dans la session courante :

```bash
source "$HOME/.bashrc"
```

---

## 🧪 5. Validation & Conformité

Conformément à la charte qualité du projet :
- **Linter Shell POSIX / Bash :** Le fichier respecte la directive `# shellcheck shell=bash` et est validé par `shellcheck` sans avertissement :
  ```bash
  shellcheck .bashrc
  ```
- **Zéro Chemin en Dur :** Toutes les références vers les répertoires personnels utilisent strictement la variable dynamique `$HOME`.
- **Idempotence :** Le démarrage du portail GTK vérifie l'absence de processus préexistant (`pgrep -u "$USER"`) et s'exécute en arrière-plan sans bloquer l'initialisation du shell.
