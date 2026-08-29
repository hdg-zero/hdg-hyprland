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
  rofi
  uwsm
  wl-copy
  wl-paste
  wpctl
)

OPTIONAL_DEPS=(
  acpi
  bluetoothctl
  btop
  gnome-system-monitor
  jq
  mullvad-gui
  nmcli
  pavucontrol
  starship
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
