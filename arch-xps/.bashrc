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

alias ls='ls --color=auto'
alias vi='vim'
alias clipboard='xclip -o | xclip -selection clipboard -i'
alias mountdocode='sshfs digitalocean:/home/catzhead/code ~/do/code'
alias unmountdocode='fusermount3 -u ~/do/code'
PS1="\[$(tput bold)\]\\$\[$(tput sgr0)\] "
