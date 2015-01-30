# Use this file to set environment variables. It is called from both
# bashrc and xinitrc, and should be sourced by display managers.

# Grab colors and set font
source ~/.palettes/bash-style/base16/default
source ~/.palettes/bash-style/base16/colors
source ~/.palettes/bash-style/base16/dark
export COLORS="Base16 Default Dark"
export FONT="Source Code Pro 12"

# Set default applications
export EDITOR=emacs
export FILES=ranger
export BROWSER=firefox
export MPLAYER=ncmpcpp
export VPLAYER=mpv
export LAUNCHER="dmenu_run -i -fn '$FONT' -nb '$BACKGROUND' -nf '$FOREGROUND' -sb '$FOREGROUND' -sf '$BACKGROUND'"

# Set application launchers (for when run outside terminal)
export TERM_SHELL=fish
export TERMINAL=termite
export TERMRUN="$TERMINAL -e"
export LAUNCH_TERMINAL="$$TERMRUN $TERM_SHELL"
export LAUNCH_EDITOR="$TERMRUN 'em -nw'"
export LAUNCH_FILES="$TERMRUN $FILES"
export LAUNCH_BROWSER=$BROWSER
export LAUNCH_MPLAYER="$TERMRUN $MPLAYER"
export LAUNCH_VPLAYER=$VPLAYER

# Fix 'less' security
export PAGER=less
unset LESSOPEN
unset LESSPIPE
export LESSSECURE=1
