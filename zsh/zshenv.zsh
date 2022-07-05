#!/bin/zsh

# `.zshenv' is sourced on all invocations of the shell, unless the -f
# option is set.  It should contain commands to set the command search
# path, plus other important environment variables. `.zshenv' should
# not contain commands that produce output or assume the shell is
# attached to a tty.

if [[ -s ~/.hostname ]]; then
    export HOSTNAME=`cat ~/.hostname`
else
    export HOSTNAME=`hostname -s`
fi

alias cp="cp -i"
alias mv="mv -i"

if [[ `uname` == "Darwin" ]]; then
    export PATH="/usr/local/bin:/usr/X11/bin/:$PATH"
    export LC_ALL=en_AU.UTF-8
fi

# Set Up Python

if [[ -d $HOME/python/$HOSTNAME ]]; then
    # This system has a system specific version of python, so use that
    export PATH=$HOME/python/$HOSTNAME/bin:$PATH
fi

if [[ -e /Library/Frameworks/Python.framework/Versions/2.7/bin ]]; then
    # Check for and if necessary set up python.org Python 2.7
    alias python.org-2.7='export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"; unalias python pip'
fi

# Check for and if necessary set up python.org Python 3.4
if [[ -e /Library/Frameworks/Python.framework/Versions/3.4/bin ]]; then
    alias python.org-3.4='export PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"; alias python=python3; alias pip=pip3'
fi
# Check for and if necessary set up python.org Python 3.5
if [[ -e /Library/Frameworks/Python.framework/Versions/3.6/bin ]]; then
    alias python.org-3.5='export PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"; alias python=python3; alias pip=pip3'
fi
# Check for and if necessary set up python.org Python 3.6
if [[ -e /Library/Frameworks/Python.framework/Versions/3.6/bin ]]; then
    alias python.org-3.6='export PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"; alias python=python3;'
fi



# Check for TeXLive:
if [[ -e /usr/texbin ]]; then
    export PATH=/usr/texbin:$PATH
    alias xelatexmk -e '$pdflatex=q/xelatex --shell-escape %O %S/'
fi

# IDL Setup
if [[ -e idl ]]; then
    export IDL_STARTUP="~/idl/startup.pro"
    export IDLUTILS_DIR="/Users/uayeb/idl/idlutils"
    export IDLSPEC2D_DIR="/Users/uayeb/idl/idlspec2d"
    export XIDL_DIR="/Users/uayeb/idl/xidl"
fi

# Set up for OSIRIS data reduction system
if [[ -e /usr/local/osiris/drs/scripts/setup_osirisDRPSetupEnv.bash ]]; then
    source /usr/local/osiris/drs/scripts/setup_osirisDRPSetupEnv.bash
    export PATH="${PATH}:${OSIRIS_ROOT}/scripts"
    export IDL_PATH="${IDL_PATH}:+${OSIRIS_ROOT}/ql2"
fi

# Add WCS Tools to path
if [[ -e /usr/local/wcstools ]]; then
    export PATH="${PATH}:/usr/local/wcstools/bin"
fi

# Add HEASOFT tools to path
if [[ -e /usr/local/heasoft/x86_64-apple-darwin14.5.0 && -e ~/.mac.env ]]; then
    export FTOOLS=/usr/local/heasoft/x86_64-apple-darwin14.5.0
    export PATH=$PATH:$FTOOLS/bin
fi

# Set the display enviornment variable if needed.
if [[ "$DISPLAY" == "" ]]; then
    export DISPLAY=:0.0
fi

if [[ -e /usr/local/2dfdr/current/bin ]]; then
    export PATH="${PATH}:/usr/local/2dfdr/current/bin"
fi

if [[ -e $HOME/bin ]]; then
    export PATH=$HOME/bin:$PATH
fi

# Add rust binaries to path
if [[ -d $HOME/.cargo/bin ]]; then
    export PATH=$HOME/.cargo/bin:$PATH;
fi

source "$HOME/.cargo/env"
