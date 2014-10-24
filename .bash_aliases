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

# administration
alias p8='ping -c 3 8.8.8.8'

# functions
md () { mkdir -p "$@" && cd "$@"; }
