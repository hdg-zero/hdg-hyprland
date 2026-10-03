# shellcheck shell=bash
umask 0002

# Ajout du répertoire binaire utilisateur local
export PATH="$PATH:$HOME/.local/bin"

# Démarrage automatique du portail GTK pour les applications Wayland (sélecteurs de fichiers)
if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -x /usr/lib/xdg-desktop-portal-gtk ] && ! pgrep -u "$USER" -f "/usr/lib/xdg-desktop-portal-[g]tk" >/dev/null 2>&1; then
  /usr/lib/xdg-desktop-portal-gtk -r >/dev/null 2>&1 &
fi
