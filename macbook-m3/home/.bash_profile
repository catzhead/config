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

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/opt/homebrew/bin/micromamba';
export MAMBA_ROOT_PREFIX='/Users/adrienbarbot/.local/share/mamb';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
