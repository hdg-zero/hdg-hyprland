# shellcheck shell=bash
#
# ~/.bashrc
#

umask 0002

# Démarrage automatique du portail GTK pour les applications Wayland (sélecteurs de fichiers)
if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -x /usr/lib/xdg-desktop-portal-gtk ] && ! pgrep -u "$USER" -f "/usr/lib/xdg-desktop-portal-[g]tk" >/dev/null 2>&1; then
  /usr/lib/xdg-desktop-portal-gtk -r >/dev/null 2>&1 &
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# BASH HISTORY
export HISTSIZE=-1
export HISTFILESIZE=-1

export HISTCONTROL=ignoredups:erasedups # ignore les doublons
shopt -s histappend			# ajoute au lieu d'ecraser
export PROMPT_COMMAND="history -a;history -c; history -r; ${PROMPT_COMMAND:-}" # sauvegarde en temps reel

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# ALIAS
alias lumi="brightnessctl s "

alias wifi-off="nmcli radio wifi off"
alias wifi-on="nmcli radio wifi on"
alias wifi-config="nmtui"

alias ls="eza --icons=always"
alias tree="eza -TL"

alias convert="magick"

alias compress-pdf="gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf"

alias cat="bat"
alias find="fd"
alias grep="rg"

# Réinitialise le pilote btusb (noyau) et relance bluetoothd en cas de gel matériel
# ou de plantage du contrôleur Bluetooth au réveil (suspend/resume).
alias fix-bt='sudo modprobe -r btusb && sudo modprobe btusb && sudo systemctl restart bluetooth'

# Added by LM Studio CLI (lms) & Local user binaries
export PATH="$PATH:$HOME/.local/bin:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

alias ll="ls -lh"
