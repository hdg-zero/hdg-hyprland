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
        hyprctl eval "hl.dispatch(hl.dsp.window.fullscreen({ action = 'toggle' }))"
        ;;
    fullscreen-output)
        hyprctl eval "hl.dispatch(hl.dsp.window.fullscreen({ action = 'toggle' }))"
        ;;
    close-window)
        hyprctl eval 'hl.dispatch(hl.dsp.window.close())'
        ;;
    terminal)
        kitty &
        ;;
    *)
        printf 'Usage: %s {workspace-prev|workspace-next|fullscreen-window|fullscreen-output|close-window|terminal}\n' "$0" >&2
        exit 2
        ;;
esac
