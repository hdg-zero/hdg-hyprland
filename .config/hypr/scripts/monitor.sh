#!/usr/bin/env bash

set -euo pipefail

INTERNAL_MONITOR="eDP-1"
INTERNAL_MODE="2880x1800@90"
INTERNAL_SCALE="1.25"
DRY_RUN=false

case "${1:-}" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
esac

notify() {
  notify-send -u normal -a "Hyprland Monitor" "Script moniteurs" "$1"
}

enable_internal() {
  local command="hl.monitor({ output = \"${INTERNAL_MONITOR}\", mode = \"${INTERNAL_MODE}\", position = \"auto\", scale = ${INTERNAL_SCALE}, bitdepth = 10 })"

  if [[ "$DRY_RUN" == true ]]; then
    printf "hyprctl eval '%s'\n" "$command"
  else
    hyprctl eval "$command"
  fi
}

disable_internal() {
  local command="hl.monitor({ output = \"${INTERNAL_MONITOR}\", disabled = true })"

  if [[ "$DRY_RUN" == true ]]; then
    printf "hyprctl eval '%s'\n" "$command"
  else
    hyprctl eval "$command"
  fi
}

if ! command -v jq >/dev/null 2>&1; then
  notify "jq est introuvable, impossible d'analyser les moniteurs."
  exit 1
fi

external_count=$(
  hyprctl monitors -j |
    jq --arg internal "$INTERNAL_MONITOR" '[.[] | select(.name != $internal and (.disabled // false | not))] | length'
)

if (( external_count > 0 )); then
  if [[ ${1:-} == "open" ]]; then
    enable_internal
    [[ "$DRY_RUN" == true ]] || notify "Écran externe détecté, écran du portable conservé."
  else
    disable_internal
    [[ "$DRY_RUN" == true ]] || notify "Écran externe détecté, écran du portable désactivé."
  fi
else
  enable_internal
  [[ "$DRY_RUN" == true ]] || notify "Aucun écran externe détecté, écran du portable conservé."
fi
