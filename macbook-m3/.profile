eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"

export PROMPT_DIRTRIM=2

shopt -s histverify

alias vi=nvim
alias ls='ls --color'
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias wks='cd ~/Workspace'

source ~/.bash-powerline.sh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/adrienbarbot/.lmstudio/bin"
