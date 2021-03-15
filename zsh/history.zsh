# Set history memory options
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_allow_clobber
setopt inc_append_history
unsetopt sharehistory
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history


# http://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

bindkey "${key[Up]}" up-line-or-local-history
bindkey "${key[Down]}" down-line-or-local-history


setopt noclobber

# Update the shared history of this zsh instance
# Search "share_history" on http://www.csse.uwa.edu.au/programming/linux/zsh-doc/zsh_17.html
alias sharehistory="fc -RI"
