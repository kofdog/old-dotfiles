#!/usr/bin/fish

# pacman
alias pacup 'pacaur -Syu'
alias pacs 'pacaur -Ss'
alias pacin 'pacaur -S'
alias pacrm 'pacaur -Rs'
alias pacrmrf 'pacaur -Rssd'
alias pacrmo 'pacaur -Rns (sudo pacman -Qtdq)'
alias paclsstd 'sudo pacman -Qen'
alias paclsaur 'sudo pacman -Qem'
alias pacclu 'paccache -ruk0'
alias paccl3 'paccache -rk3'
alias paccl2 'paccache -rk2'
alias paccl1 'paccache -rk1'
alias paccla 'paccache -rk0'

# systemd
alias ssysup 'sudo systemctl start'
alias ssysdown 'sudo systemctl stop'
alias ssyson 'sudo systemctl enable'
alias ssysoff 'sudo systemctl disable'
alias ssysstat 'sudo systemctl status'
alias ssyslsall 'sudo systemctl list-units'
alias ssyslstim 'sudo systemctl list-timers'
alias ssyslsfail 'sudo systemctl --failed'
alias ssyslog 'sudo journalctl -xe'

alias sysup 'systemctl --user start'
alias sysdown 'systemctl --user stop'
alias syson 'systemctl --user enable'
alias sysoff 'systemctl --user disable'
alias sysstat 'systemctl --user status'
alias syslsall 'systemctl --user list-units'
alias syslstim 'systemctl --user list-timers'
alias syslsfail 'systemctl --user --failed'
alias syslog 'journalctl -xe'

# navigation
alias u 'cd ..'
alias uu 'cd ../..'
alias uuu 'cd ../../..'
alias uuuu 'cd ../../../..'
alias uuuuu 'cd ../../../../..'

# administration
alias p8 'ping -c 3 8.8.8.8'

# color support
alias ls 'ls --color=auto'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# ls
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'

# aesthetic
alias cleary 'clear; archey3'

# vim keybindings
alias info 'info --vi-keys'

# quick launchers
alias em 'emacs -nw'

# Make directory (recursive) and move there
function md
    mkdir -p $argv; cd $argv
end
