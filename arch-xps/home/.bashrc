#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

XDG_CONFIG_HOME=$HOME/.config

export PATH=$PATH:~/.local/bin:~/.scripts
export FLATPAK_SYSTEM_DIR=/infra/flatpak
export LIBVA_DRIVER_NAME=iHD
export HISTCONTROL=ignorespace
export DOCKER_CONFIG=$HOME/.config/docker

# recall history command without executing it
shopt -s histverify

alias ls='ls --color=auto'
alias vi='nvim'
alias clipboard='xclip -o | xclip -selection clipboard -i'
alias kbde='setxkbmap de'
alias kbus='setxkbmap us'
alias kbfr='setxkbmap fr'

PS1="\[$(tput bold)\]\\$\[$(tput sgr0)\] "
