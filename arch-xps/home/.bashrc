#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

XDG_CONFIG_HOME=$HOME/.config

#if [ "$TERM" != "linux" ]; then
  #powerline-daemon -q
  #POWERLINE_BASH_CONTINUATION=1
  #POWERLINE_BASH_SELECT=1
  #. /usr/share/powerline/bindings/bash/powerline.sh
#fi

export PATH=$PATH:~/.scripts

alias ls='ls --color=auto'
alias vi='gvim'
alias clipboard='xclip -o | xclip -selection clipboard -i'
alias mountdocode='sshfs digitalocean:/home/catzhead/code ~/do/code'
alias unmountdocode='fusermount3 -u ~/do/code'
alias kbde='setxkbmap de'
alias kbus='setxkbmap us'
alias kbfr='setxkbmap fr'
alias play='ffplay -loglevel quiet'
PS1="\[$(tput bold)\]\\$\[$(tput sgr0)\] "
