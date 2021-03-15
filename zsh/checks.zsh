# checks (stolen from zshuery)
if [[ $(uname) = 'Linux' ]]; then
    IS_LINUX=1
fi

if [[ $(uname) = 'Darwin' ]]; then
    IS_MAC=1
fi

if [[ -x `which git 2>/dev/null` ]]; then
	HAS_GIT=1
fi

if [[ -x `which hg 2>/dev/null` ]]; then
	HAS_HG=1
fi

if [[ -x `which fossil 2>/dev/null` ]]; then
	HAS_FOSSIL=1
fi

if [[ -x `which brew 2>/dev/null` ]]; then
    HAS_BREW=1
fi

if [[ -x `which apt-get 2>/dev/null` ]]; then
    HAS_APT=1
fi

if [[ -x `which yum 2>/dev/null` ]]; then
    HAS_YUM=1
fi

if [[ -x `which virtualenv 2>/dev/null` ]]; then
    HAS_VIRTUALENV=1
fi

if [[ -n $SSH_CONNECTION ]]; then
	IS_REMOTE=1
fi
