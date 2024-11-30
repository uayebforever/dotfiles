#!/bin/zsh

# `.zshrc' is sourced in interactive shells. It should contain
# commands to set up aliases, functions, options, key bindings, etc.


source ~/.dotfiles/zsh/checks.zsh


# Set up oh-my-zsh

export ZSH=$HOME/.dotfiles/oh-my-zsh

#ZSH_THEME="agnoster"

plugins=(git mercurial pip sudo)
if [ -n $IS_MAC ]; then
	plugins=($plugins osx brew)
fi
if [ -n $HAS_APT ]; then
	plugins=($plugins)
fi

# The next line disables oh-my-zsh's automatic updates, and then loads it.
DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# Setup 2dfdr
# if [[ -e /usr/local/2dfdr ]]; then
#     echo "2dfdr found in /usr/local/2dfdr...   setting it up...."
#     export DRCONTROL_DIR=/usr/local/2dfdr
#     source $DRCONTROL_DIR/2dfdr_setup_sh
# else if [[ -e ~/Research/software/2dfdr-macosx_i386 ]]; then
#     echo "2dfdr found in ~/Research/software/2dfdr-macosx_i386...   setting it up..."
#     export DRCONTROL_DIR=~/Research/software/2dfdr-macosx_i386
#     source $DRCONTROL_DIR/2dfdr_setup_sh
# fi
# fi


# Set up home for "workon" (part of virtualenvwrapper)
if [[ -e $HOME/python/virtualenvs ]] && [[ -e /usr/local/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME="${HOME}/python/virtualenvs"
    source /usr/local/bin/virtualenvwrapper.sh
fi


# Set up keyboard keys
#autoload zkbd
#zkbd
#source ~/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}
typeset -g -A key

key[F1]='^[OP'
key[F2]='^[OQ'
key[F3]='^[OR'
key[F4]='^[OS'
key[F5]='^[[15~'
key[F6]='^[[17~'
key[F7]='^[[18~'
key[F8]='^[[19~'
key[F9]='^[[20~'
key[F10]='^[[21~'
key[F11]='^[[23~'
key[F12]='^[[24~'
key[Backspace]='^?'
key[Insert]=''''
key[Home]=''''
key[PageUp]=''''
key[Delete]='^[[3~'
key[End]=''''
key[PageDown]=''''
key[Up]='^[[A'
key[Left]='^[[D'
key[Down]='^[[B'
key[Right]='^[[C'
key[Menu]=''''


source ~/.dotfiles/zsh/colors.zsh
source ~/.dotfiles/zsh/prompt.zsh
source ~/.dotfiles/zsh/completion.zsh
source ~/.dotfiles/zsh/functions.zsh


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vi'
else
   export EDITOR='subl -w -n'
fi


# Create the namedir command:
namedir () { $1=$PWD ;  : ~$1 }

# Have titlebar of xterms update on directory change
chpwd () { print -Pn "\e]2;%m:%~\a" }
#     see zshmisc(1) for a list of substitutions

# Setup the directory stack
DIRSTACKSIZE=8
setopt autopushd pushdminus pushdsilent pushdtohome
alias dh='dirs -v'

unsetopt cdablevars

# Set the PROMPT
#POSTEDIT=`echotc se`
#PROMPT="%{$fg[green]%}%1d%{$reset_color%}> %S"

if [[ -e ~/.dotfiles/zsh/history.zsh ]]; then
    source ~/.dotfiles/zsh/history.zsh
fi 

export CLICOLOR=1

if [[ -e ~/.zshpaths ]]; then
    source ~/.zshpaths
fi 
if [[ -e ~/.zshlocal ]]; then
    source ~/.zshlocal
fi 



# Custom Environment Stuff

export ETS_TOOLKIT=qt4

if (which fortune > /dev/null); then
    echo ""
    fortune
fi
