#!/bin/bash

# pacman
alias search='pacaur -Ss'
alias inst='pacaur -S'
alias upgrade='pacaur -Syu'
alias remove='pacaur -Rs'
alias purge='pacaur -Rssd'
alias cleanu='paccache -ruk0'
alias clean2='paccache -rk2'
alias cleanall='paccache -rk0'

# systemd
alias sysup='sudo systemctl start'
alias sysdown='sudo systemctl stop'
alias syson='sudo systemctl enable'
alias sysoff='sudo systemctl disable'

# navigation
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'
alias uuuuu='cd ../../../../..'
md () { mkdir -p "$@" && cd "$@"; }

# vim
vimp () { vim $( find "$@" -maxdepth 1 -type f ); }

# administration
alias p8='ping -c 3 8.8.8.8'

# color support
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# aesthetic
alias cleary='clear; archey3'

# vim keybindings
alias info='info --vi-keys'

# useful for long-running commands: <command>; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\=\s*//;s/[;&|]\s*alert$//'\'')"'
