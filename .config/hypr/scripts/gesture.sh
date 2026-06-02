#!/usr/bin/env sh

set -eu

case "${1:-}" in
    workspace-prev)
        hyprctl dispatch 'hl.dsp.focus({ workspace = "e-1" })'
        ;;
    workspace-next)
        hyprctl dispatch 'hl.dsp.focus({ workspace = "e+1" })'
        ;;
    fullscreen-window)
        hyprctl dispatch 'hl.dsp.window.fullscreen({ action = "toggle", mode = 1 })'
        ;;
    fullscreen-output)
        hyprctl dispatch 'hl.dsp.window.fullscreen({ action = "toggle", mode = 0 })'
        ;;
    close-window)
        hyprctl dispatch 'hl.dsp.window.close()'
        ;;
    terminal)
        kitty
        ;;
    *)
        printf 'Usage: %s {workspace-prev|workspace-next|fullscreen-window|fullscreen-output|close-window|terminal}\n' "$0" >&2
        exit 2
        ;;
esac
