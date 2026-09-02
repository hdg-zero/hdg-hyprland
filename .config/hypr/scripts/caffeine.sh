#!/usr/bin/env bash
#
# Script de contrôle du mode Caféine (anti-sommeil / maintien de l'écran allumé)
# Utilisable en CLI, par raccourci Hyprland ou par Quickshell.

set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.state"

get_status() {
  if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "enabled" ]; then
    return 0
  fi
  return 1
}

qs_call() {
  local method="$1"
  if command -v quickshell >/dev/null 2>&1; then
    quickshell ipc call caffeine "$method"
  elif command -v qs >/dev/null 2>&1; then
    qs ipc call caffeine "$method"
  else
    return 1
  fi
}

enable_caffeine() {
  if pidof quickshell >/dev/null 2>&1 && qs_call "enable"; then
    return 0
  fi

  mkdir -p "$(dirname "$STATE_FILE")"
  printf '%s' "enabled" > "$STATE_FILE"
  killall -STOP hypridle 2>/dev/null || true

  if command -v brightnessctl >/dev/null 2>&1; then
    brightnessctl -r >/dev/null 2>&1 || true
  fi

  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' >/dev/null 2>&1 || true
  fi

  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Caffeine" -u normal "☕ Mode Caféine activé" "L'écran ne se mettra plus en veille." >/dev/null 2>&1 || true
  fi
}

disable_caffeine() {
  if pidof quickshell >/dev/null 2>&1 && qs_call "disable"; then
    return 0
  fi

  mkdir -p "$(dirname "$STATE_FILE")"
  printf '%s' "disabled" > "$STATE_FILE"
  killall -CONT hypridle 2>/dev/null || true

  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Caffeine" -u normal "☕ Mode Caféine désactivé" "Gestion normale de l'inactivité rétablie." >/dev/null 2>&1 || true
  fi
}

toggle_caffeine() {
  if pidof quickshell >/dev/null 2>&1 && qs_call "toggle"; then
    return 0
  fi

  if get_status; then
    disable_caffeine
  else
    enable_caffeine
  fi
}

ACTION="${1:-toggle}"

case "$ACTION" in
  toggle)
    toggle_caffeine
    ;;
  enable|on)
    enable_caffeine
    ;;
  disable|off)
    disable_caffeine
    ;;
  status)
    if get_status; then
      echo "enabled"
      exit 0
    else
      echo "disabled"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 [toggle|enable|disable|status]" >&2
    exit 2
    ;;
esac
