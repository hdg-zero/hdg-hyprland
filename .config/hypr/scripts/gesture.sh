#!/usr/bin/env sh

set -eu

case "${1:-}" in
    workspace-prev)
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))'
        ;;
    workspace-next)
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))'
        ;;
    fullscreen-window)
        hl_cmd="hl.dsp.window.fullscreen({ action = 'toggle', mode = 1 })"
        hyprctl eval "hl.dispatch(${hl_cmd})"
        ;;
    fullscreen-output)
        hl_cmd="hl.dsp.window.fullscreen({ action = 'toggle', mode = 0 })"
        hyprctl eval "hl.dispatch(${hl_cmd})"
        ;;
    close-window)
        hyprctl eval 'hl.dispatch(hl.dsp.window.close())'
        ;;
    terminal)
        kitty
        ;;
    *)
        printf 'Usage: %s {workspace-prev|workspace-next|fullscreen-window|fullscreen-output|close-window|terminal}\n' "$0" >&2
        exit 2
        ;;
esac
