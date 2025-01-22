# Modified from agnoster's Theme - https://gist.github.com/3712874
#
# # README
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

WC=/usr/bin/wc

nl='
'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
# See also https://wiki.archlinux.org/index.php/zsh#Prompt_variables
#default_bg="$bg[black]"
default_bg=""

prompt_segment() {
#  local fore  back
  # [[ -n $2 ]] && back="$bg[$2]" || back=""
  # [[ -n $1 ]] && fore="$fg_no_bold[$1]" || fore="$fg[white]"

  # echo -n "%{${back}%}%{${fore}%}"
  #echo -n "%{$fg[$1]$bg[$2]%}"
  echo -n "%{$fg[$1]%}"
  [[ -n $3 ]] && echo -n $3 && echo -n %{${reset_color}%}
}

# End the prompt, closing any open segments
prompt_end() {
  # if [[ -n $CURRENT_BG ]]; then
  #   echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  # else
  #   echo -n "%{%k%}"
  # fi
  echo -n "%{${reset_color}%}$newline"
  newline=' '
  CURRENT_BG=''
}

### Prompt Helpers

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname -s
}

local newline=" "


# Prompt inline autocompletion:
# https://github.com/zsh-users/zsh-autosuggestions
if [[ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
#  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
ignore_usernames=(agreen uayeb)
prompt_context() {
  local user=`whoami`

  # This next line uses array indexing to see if the element is missing:
  # http://zshwiki.org/home/scripting/array
  if [[ ${ignore_usernames[(i)${user}]} -eq 3 || -n "$SSH_CLIENT" ]]; then
    prompt_segment green black "${user}"
    prompt_segment gray black "@"
    prompt_segment blue black "$(box_name)"
    prompt_segment gray black ":"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  if [[ -n $HAS_GIT ]]; then
    local ref dirty mode repo_path
    repo_path=$(git rev-parse --git-dir 2>/dev/null)

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      prompt_segment gray black " (git:"
      newline="$nl "
      dirty=$(parse_git_dirty)
      ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
      if [[ -n $dirty ]]; then
        prompt_segment yellow black
      else
        prompt_segment green black
      fi

      if [[ -e "${repo_path}/BISECT_LOG" ]]; then
        mode=" <B>"
      elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
        mode=" >M<"
      elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
        mode=" >R>"
      fi

      setopt promptsubst
      autoload -Uz vcs_info

      zstyle ':vcs_info:*' enable git
      zstyle ':vcs_info:*' get-revision true
      zstyle ':vcs_info:*' check-for-changes true
      zstyle ':vcs_info:*' stagedstr '✚'
      zstyle ':vcs_info:git:*' unstagedstr '●'
      zstyle ':vcs_info:*' formats ' %u%c'
      zstyle ':vcs_info:*' actionformats ' %u%c'
      vcs_info
      echo -n "${ref/refs\/heads\// }${vcs_info_msg_0_%% }${mode}"
      prompt_segment gray black ")"
    fi
  fi
}

prompt_hg() {
  if [[ -n $HAS_HG ]]; then
    local rev status
    if $(hg id >/dev/null 2>&1); then
      prompt_segment gray black " (hg:"
      newline="$nl "
      if hg prompt >/dev/null 2>&1; then
        if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
          # if files are not added
          prompt_segment red white
          st='±'
        elif [[ -n $(hg prompt "{status|modified}") ]]; then
          # if any modification
          prompt_segment yellow black
          st='±'
        else
          # if working copy is clean
          prompt_segment green black
        fi
        echo -n $(hg prompt "{rev}@{branch}") $st 
      else
        st=""
        rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
        branch=$(hg id -b 2>/dev/null)
        if `hg st | grep -Eq "^\?"`; then
          prompt_segment red black
          st='±'
        elif `hg st | grep -Eq "^(M|A)"`; then
          prompt_segment yellow black
          st='±'
        else
          prompt_segment green black
        fi
        echo -n "$rev@$branch" $st 

      fi
      prompt_segment gray black ")"
    fi
  fi
}

prompt_fossil() {
  local rev status
  if [[ -n $HAS_FOSSIL ]]; then
    if fossil status > /dev/null 2>&1; then
      prompt_segment gray black " (fossil:"
      newline="$nl "
      st=""
      branch=`fossil branch|grep -e '^*'`
      if [[ ! -n $fast && -n `fossil extras` ]]; then
        prompt_segment red black
        st='±'
      elif [[ ! -n $fast && -n `fossil changes` ]]; then
        prompt_segment yellow black
        st='±'
      else
        if [[ -n $fast ]]; then
          prompt_segment white black
        else
          prompt_segment green black
        fi
      fi
      echo -n "$branch:s/* //" $st
      prompt_segment gray black ")"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {

  prompt_segment orange black '%~'

  if [[ $(echo $(pwd | sed -e "s,^$HOME,~,")|$WC -m) -gt 20 ]]; then
    newline="$nl "
  fi
}

# Virtualenv: current working virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=1
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ (-n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT) || -n $PYTHONPATH ]]; then
    if [[ -n $virtualenv_path ]]; then
      if [[ $(basename $virtualenv_path) =~ ".?venv" ]]; then
          virtualenv_path=$(dirname $virtualenv_path)
        fi
        prompt_segment blue black " (`basename $virtualenv_path`"
    else
      prompt_segment blue black " (sys-python"      
    fi
    if [[ -n $PYTHONPATH ]]; then
      prompt_segment red black "+"
    fi
    prompt_segment blue black ")"
  fi
}

# Current Java per JAVA_HOME
prompt_javahome() {
  if [[ -n $JAVA_HOME ]]; then
    if [[ "${JAVA_HOME}" == *".sdkman"* ]]; then
      if [[ "${JAVA_HOME}" != *"current"* ]]; then
        java_version="$(basename ${JAVA_HOME})"
      fi
    else
      java_version="$(echo $JAVA_HOME | cut -f 5 -d \/)"
    fi
  fi

  if [[ -n "${java_version}" ]]; then
      prompt_segment gray black " (java:"
      prompt_segment blue black " `echo $java_version | cut -f 5 -d \/`"
      prompt_segment gray black ")"
  fi

}


source ~/.dotfiles/zsh/prompt_time.zsh
prompt_exectime(){
  if [[ "$ZSH_EXEC_TIME" -ge "5.0" ]]; then
    prompt_segment blue black "⌚︎$ZSH_EXEC_TIME "
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  RETVAL=$?
  prompt_exectime
  [[ $RETVAL -ne 0 ]] && prompt_segment red black "✘:$RETVAL "
  [[ $UID -eq 0 ]] && prompt_segment yellow black "⚡ "
  [[ $(jobs -l | $WC -l) -gt 0 ]] && prompt_segment cyan black "⚙ "
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_context
  prompt_dir
  # prompt_status
  if [[ ! -n $fast ]]; then
    prompt_git
    prompt_hg
    prompt_fossil
  fi
  prompt_virtualenv
  prompt_javahome
  prompt_end
}

PROMPT='$(build_prompt)> '

RPROMPT='$(prompt_status)'

