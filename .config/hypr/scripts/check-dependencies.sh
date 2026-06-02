#!/usr/bin/env bash

set -euo pipefail

dependencies=(
  acpi
  bitwarden-desktop
  brightnessctl
  cliphist
  hypridle
  hyprland-monitor-attached
  hyprlock
  hyprpaper
  hyprshot
  jq
  kitty
  libinput-gestures
  nautilus
  notify-send
  playerctl
  rfkill
  rofi
  swaync-client
  udiskie
  uwsm
  wlogout
  wl-copy
  wl-paste
  wpctl
)

optional_dependencies=(
  hyprsunset
  mullvad-gui
)

check_dependency() {
  local dependency=$1
  local required=$2

  if command -v "$dependency" >/dev/null 2>&1; then
    printf 'ok       %s\n' "$dependency"
  elif [[ $required == true ]]; then
    printf 'missing  %s\n' "$dependency"
  else
    printf 'optional %s\n' "$dependency"
  fi
}

for dependency in "${dependencies[@]}"; do
  check_dependency "$dependency" true
done

for dependency in "${optional_dependencies[@]}"; do
  check_dependency "$dependency" false
done
