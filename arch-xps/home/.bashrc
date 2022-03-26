#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/bash-completion/bash_completion

XDG_CONFIG_HOME=$HOME/.config

export PATH=$PATH:~/.local/bin:~/.scripts
export FLATPAK_SYSTEM_DIR=/infra/flatpak
export LIBVA_DRIVER_NAME=iHD
export HISTCONTROL=ignorespace
export DOCKER_CONFIG=$HOME/.config/docker
export EDITOR=nvim
export VISUAL=$EDITOR
export GPG_TTY=$(tty)

# Go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# scaling issue with alacritty
# export WINIT_X11_SCALE_FACTOR=1

# recall history command without executing it
shopt -s histverify

alias ls='ls --color=auto'
alias vi='nvim'
alias clipboard='xclip -o | xclip -selection clipboard -i'
alias kbde='setxkbmap de'
alias kbus='setxkbmap us'
alias kbfr='setxkbmap fr'
alias grep='grep --color=always'
alias grepl='grep --color=always -n'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias catn='bat'

PS1="\[$(tput bold)\]\\$\[$(tput sgr0)\] "
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
