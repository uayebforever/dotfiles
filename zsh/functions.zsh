# -------------------------------------------------------------------
# compressed file expander
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------
ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar $1;;
          *.gz) gunzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *.dmg) hdiutul mount $1;; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -------------------------------------------------------------------
# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM.
# from https://github.com/paulmillr/dotfiles
# -------------------------------------------------------------------
function ram() {
  local sum
  local items
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
  else
    sum=0
    for i in `ps aux | grep -i "$app" | grep -v "grep" | awk '{print $6}'`; do
      sum=$(($i + $sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    if [[ $sum != "0" ]]; then
      echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM."
    else
      echo "There are no processes with pattern '${fg[blue]}${app}${reset_color}' are running."
    fi
  fi
}

# -------------------------------------------------------------------
# display a neatly formatted path
# -------------------------------------------------------------------
path() {
  echo $PATH | tr ":" "\n" | \
    awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
           sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
           sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
           sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
           sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
           sub(\"/.rvm\",  \"$fg_no_bold[red]/.rvm$reset_color\"); \
           print }"
}

# -------------------------------------------------------------------
# Mac specific functions
# -------------------------------------------------------------------
if [[ $IS_MAC -eq 1 ]]; then

    # view man pages in Preview
    pman() { ps=`mktemp -t manpageXXXX`.ps ; man -t $@ > "$ps" ; open "$ps" ; }

    # function to show interface IP assignments
    ips() { foo=`/Users/mark/bin/getip.py; /Users/mark/bin/getip.py en0; /Users/mark/bin/getip.py en1`; echo $foo; }

    # notify function - http://hints.macworld.com/article.php?story=20120831112030251
    notify() { automator -D title=$1 -D subtitle=$2 -D message=$3 ~/Library/Workflows/DisplayNotification.wflow }

    # Remote Mount (sshfs)
    # creates mount folder and mounts the remote filesystem
    rmount() {
      local host folder mname
      host="${1%%:*}:"
      [[ ${1%:} == ${host%%:*} ]] && folder='' || folder=${1##*:}
      if [[ -n $2 ]]; then
        mname=$2
      else
        mname=${folder##*/}
        [[ "$mname" == "" ]] && mname=${host%%:*}
      fi
      if [[ $(grep -i "host ${host%%:*}" ~/.ssh/config) != '' ]]; then
        mkdir -p ~/mounts/$mname > /dev/null
        sshfs $host$folder ~/mounts/$mname -oauto_cache,reconnect,defer_permissions,negative_vncache,volname=$mname,noappledouble && echo "mounted ~/mounts/$mname"
      else
        echo "No entry found for ${host%%:*}"
        return 1
      fi
    }

    # Remote Umount, unmounts and deletes local folder (experimental, watch you step)
    rumount() {
      if [[ $1 == "-a" ]]; then
        ls -1 ~/mounts/|while read dir
        do
          [[ -d $(mount|grep "mounts/$dir") ]] && umount ~/mounts/$dir
          [[ -d $(ls ~/mounts/$dir) ]] || rm -rf ~/mounts/$dir
        done
      else
        [[ -d $(mount|grep "mounts/$1") ]] && umount ~/mounts/$1
        [[ -d $(ls ~/mounts/$1) ]] || rm -rf ~/mounts/$1
      fi
    }

fi

# -------------------------------------------------------------------
# Function to highlight strings in output:
#   see: http://superuser.com/a/199106
# -------------------------------------------------------------------
function highlight()
{
    sed "s/$1/`tput smso`&`tput rmso`/g" "${2:--}"
}
