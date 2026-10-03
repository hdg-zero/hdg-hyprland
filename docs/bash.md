# 🐚 Configuration Shell Bash (`.bashrc`)

Documentation technique de la configuration du shell interactif **Bash** pour l'environnement **Hyprland 0.56+ / Wayland**.

---

## 🎯 1. Rôle & Périmètre

Le fichier `.bashrc` situé à la racine du dépôt constitue la configuration standard du shell utilisateur interactif :
- **Portabilité & Zéro Chemin en Dur :** Utilisation stricte des variables d'environnement (`$HOME`, `$USER`, `$WAYLAND_DISPLAY`) garantissant un fonctionnement immédiat sur n'importe quel compte utilisateur ou machine.
- **Permissions Sécurisées :** Définition d'un masque de création de fichiers `umask 0002` adapté aux environnements multi-projets.
- **Binaire Utilisateur :** Enrichissement du `$PATH` pour inclure `$HOME/.local/bin` (utilisé par les outils CLI locaux, scripts utilisateurs et SDKs).
- **Intégration Graphique Wayland (XDG Desktop Portal) :** Détection d'affichage Wayland (`$WAYLAND_DISPLAY`) et lancement automatique asynchrone non-bloquant de `/usr/lib/xdg-desktop-portal-gtk` pour garantir le bon fonctionnement des boîtes de dialogue et sélecteurs de fichiers dans les applications Wayland si le portail n'est pas déjà actif.
- **Synergie de l'Environnement :** Conçu pour s'harmoniser avec l'émulateur de terminal GPU [Kitty](file:///Projets/github/hdg-hyprland/.config/kitty/kitty.conf) et le prompt universel [Starship](file:///Projets/github/hdg-hyprland/.config/starship.toml).

---

## 🏛️ 2. Structure & Contenu

```bash
# shellcheck shell=bash
umask 0002

# Ajout du répertoire binaire utilisateur local
export PATH="$PATH:$HOME/.local/bin"

# Démarrage automatique du portail GTK pour les applications Wayland (sélecteurs de fichiers)
if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -x /usr/lib/xdg-desktop-portal-gtk ] && ! pgrep -u "$USER" -f "/usr/lib/xdg-desktop-portal-[g]tk" >/dev/null 2>&1; then
  /usr/lib/xdg-desktop-portal-gtk -r >/dev/null 2>&1 &
fi
```

---

## 🔗 3. Déploiement & Création du Lien Symbolique

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

## 🧪 4. Validation & Conformité

Conformément à la charte qualité du projet :
- **Linter Shell POSIX / Bash :** Le fichier respecte la directive `# shellcheck shell=bash` et est validé par `shellcheck` sans avertissement :
  ```bash
  shellcheck .bashrc
  ```
- **Idempotence :** Le démarrage du portail GTK vérifie l'absence de processus préexistant (`pgrep -u "$USER"`) et s'exécute en arrière-plan sans bloquer l'initialisation du shell.
