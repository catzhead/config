eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"

shopt -s histverify

alias vi=nvim
alias ls='ls --color'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'

source ~/.bash-powerline.sh
