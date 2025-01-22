autoload -Uz add-zsh-hook

prompt_time_path="/tmp/zsh_data/${USER}.prompt_time.${$}"

function roundseconds (){
  # rounds a number to 3 decimal places
  echo m=$1";h=0.5;scale=4;t=1000;if(m<0) h=-0.5;a=m*t+h;scale=3;a/t;" | bc
}

function preexec.starttime (){
  # places the epoch time in ns into shared memory
  if [[ ! -d "$(dirname ${prompt_time_path})" ]]; then
    mkdir "$(dirname ${prompt_time_path})"
  fi
  gdate +%s.%N >|"${prompt_time_path}"
}
add-zsh-hook preexec preexec.starttime

function precmd.exectime (){
  # reads stored epoch time and subtracts from current
  if [[ -f "${prompt_time_path}" ]]; then
    local endtime=$(gdate +%s.%N)
    local starttime=$(cat "${prompt_time_path}")
    export ZSH_EXEC_TIME=$(roundseconds $(echo $(eval echo "$endtime - $starttime") | bc))
  fi
  rm -f "${prompt_time_path}"
}
add-zsh-hook precmd precmd.exectime

function zshexit.prompt_time_path (){
      if [[ -f "${prompt_time_path}" ]]; then
        rm "${prompt_time_path}"
    fi
}
add-zsh-hook zshexit zshexit.prompt_time_path