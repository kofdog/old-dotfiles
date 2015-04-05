#!/bin/bash

# terminal title bar
wname() { echo -en "\033]0;$@\007"; }
alias ranger='wname ranger; ranger'
alias ncmpcpp='wname ncmpcpp; ncmpcpp'

# pacman
alias pacup='pacaur -Syu'
alias pacs='pacaur -Ss'
alias pacin='pacaur -S'
alias pacrm='pacaur -Rs'
alias pacrmrf='pacaur -Rssd'
alias pacrmo='pacaur -Rns $(sudo pacman -Qtdq)'
alias paclsstd='sudo pacman -Qen'
alias paclsaur='sudo pacman -Qem'
alias pacclu='paccache -ruk0'
alias paccl3='paccache -rk3'
alias paccl2='paccache -rk2'
alias paccl1='paccache -rk1'
alias paccla='paccache -rk0'

# systemd
alias ssysup='sudo systemctl start'
alias ssysdown='sudo systemctl stop'
alias ssysre='sudo systemctl restart'
alias ssyson='sudo systemctl enable'
alias ssysoff='sudo systemctl disable'
alias ssysstat='sudo systemctl status'
alias ssyslsall='sudo systemctl list-units'
alias ssyslstim='sudo systemctl list-timers'
alias ssyslsfail='sudo systemctl --failed'
alias ssyslog='sudo journalctl -xe'

alias sysup='systemctl --user start'
alias sysdown='systemctl --user stop'
alias sysre='systemctl --user restart'
alias syson='systemctl --user enable'
alias sysoff='systemctl --user disable'
alias sysstat='systemctl --user status'
alias syslsall='systemctl --user list-units'
alias syslstim='systemctl --user list-timers'
alias syslsfail='systemctl --user --failed'
alias syslog='journalctl -xe'

# navigation
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'
alias uuuuu='cd ../../../../..'
md () { mkdir -p "$@" && cd "$@"; }

# quick cd
alias eudy='cd ~/Documents/code/eudyptula'
alias desk='cd ~/.local/share/applications'
alias sand='cd ~/AndroidStudioProjects/Sandbox/app/src/main/java/com/example/mike/sandbox'
alias sdesk='cd /usr/share/applications'

# vim
alias vim='wname vim; vim'
alias testvim='vim ~/Documents/code/eudyptula/01-helloworld/hello_world.c'
vimp () { vim $( find "$@" -maxdepth 1 -type f ); }

# administration
alias dirsize='du -h -d 1 | sort -rh | less'
alias filesize='du -hS | sort -rh | less'
alias p8='ping -c 3 8.8.8.8'

# color support
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls
alias l='ls'
alias s='ls'
alias sl='ls'

alias la='ls -A'
alias lh='ls -alFh'
alias ll='ls -alF'

# aesthetic
alias cleary='clear; archey3'

# vim keybindings
alias info='info --vi-keys'

# quick launchers
alias em='wname emacs; em -nw'

# fix sudo
alias sudo='sudo '

# useful for long-running commands: <command>; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\=\s*//;s/[;&|]\s*alert$//'\'')"'
