#!/bin/bash

# ports
alias portup='sudo portsnap fetch update && sudo portmaster -a'
alias portin='sudo portmaster'
alias ports='sudo pkg search -o'

# aptitude
alias aptup='sudo aptitude update && sudo aptitude upgrade'
alias aptin='sudo aptitude install'
alias apts='aptitude search'
alias aptrm='sudo aptitude remove'

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

# quick ssh
alias aule='ssh kofdog@aule'
alias ulmo='ssh kofdog@ulmo'

alias alec="ulmo -t 'tmux attach -t alec; bash -l'"
alias eudyptula="aule -t 'tmux attach -t eudyptula-challenge; bash -l'"
alias guess="aule -t 'tmux attach -t guess-chinese; bash -l'"
alias murmur="aule -t 'tmux attach -t murmur; bash -l'"
alias prick="aule -t 'tmux attach -t pricktionary; bash -l'"
alias srweb="ulmo -t 'tmux attach -t srweb; bash -l'"
alias sunshine="aule -t 'tmux attach -t sunshine; bash -l'"

# administration
alias dirsize='du -h -d 1 | sort -rh | less'
alias filesize='du -hS | sort -rh | less'
alias p8='ping -c 3 8.8.8.8'

# color support
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls -G --color=auto'
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
alias clc='clear; screenfetch'
alias cleary='clear; archey'

# vim keybindings
alias info='info --vi-keys'

# quick launchers
alias emc='em -nw'
alias nv='nvim'

# fix sudo
alias sudo='sudo '

# useful for long-running commands: <command>; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\=\s*//;s/[;&|]\s*alert$//'\'')"'
