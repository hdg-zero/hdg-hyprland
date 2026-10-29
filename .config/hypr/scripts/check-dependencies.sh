#!/usr/bin/env bash

set -euo pipefail

REQUIRED_DEPS=(
  brightnessctl
  cliphist
  hypridle
  hyprland
  hyprlock
  hyprpaper
  hyprshot
  kitty
  notify-send
  playerctl
  quickshell
  uwsm
  wl-copy
  wl-paste
  wpctl
  # Outils des alias du .bashrc
  bat
  eza
  fd
  rg
)

OPTIONAL_DEPS=(
  bitwarden-desktop
  blueman-applet
  bluetoothctl
  btop
  gnome-system-monitor
  hyprsunset
  jq
  libinput-gestures
  mullvad-gui
  nautilus
  nm-connection-editor
  nmcli
  pavucontrol
  powerprofilesctl
  starship
  udiskie
)

missing_required=0
missing_optional=0

echo "=== Vérification des dépendances hdg-hyprland ==="
echo ""
echo "-- Dépendances obligatoires --"

for dep in "${REQUIRED_DEPS[@]}"; do
  if command -v "$dep" >/dev/null 2>&1; then
    printf '  [OK]       %s\n' "$dep"
  else
    printf '  [MANQUANT] %s\n' "$dep"
    missing_required=$((missing_required + 1))
  fi
done

# Agent polkit : hors du PATH (/usr/lib/hyprpolkitagent), on vérifie son service utilisateur.
if systemctl --user is-enabled --quiet hyprpolkitagent.service 2>/dev/null; then
  printf '  [OK]       %s\n' "hyprpolkitagent (service utilisateur)"
else
  printf '  [MANQUANT] %s\n' "hyprpolkitagent (systemctl --user enable --now hyprpolkitagent.service)"
  missing_required=$((missing_required + 1))
fi

echo ""
echo "-- Dépendances optionnelles --"

for dep in "${OPTIONAL_DEPS[@]}"; do
  if command -v "$dep" >/dev/null 2>&1; then
    printf '  [OK]       %s\n' "$dep"
  else
    printf '  [OPTIONNEL] %s\n' "$dep"
    missing_optional=$((missing_optional + 1))
  fi
done

echo ""
echo "=== Synthèse ==="
echo "Obligatoires manquantes : $missing_required"
echo "Optionnelles manquantes : $missing_optional"

if [ "$missing_required" -gt 0 ]; then
  echo "Erreur : des dépendances obligatoires sont manquantes !" >&2
  exit 1
else
  echo "Toutes les dépendances obligatoires sont présentes."
  exit 0
fi
