# Use this file to set environment variables. It is called from both
# bashrc and xinitrc, and should be sourced by display managers.

# Add personal scripts to path
#PATH=~/.bin:$PATH
#PATH=~/.gopath/bin:$PATH

# Grab colors and set font
source ~/.palettes/bash-style/base16/monokai
source ~/.palettes/bash-style/base16/colors
source ~/.palettes/bash-style/base16/dark
export FONT="Meslo LG S-10"

# Set default applications
export EDITOR=vim
export PAGER=less
export FILES=ranger
export BROWSER=google-chrome-stable
export MPLAYER=ncmpcpp
export VPLAYER=mpv
export LAUNCHER="dmenu_run -i -fn $FONT -nb $BACKGROUND -nf $FOREGROUND -sb $FOREGROUND -sf $BACKGROUND"

# Set application launchers (for when run outside terminal)
export LAUNCH_TERM=urxvtc
export TERMRUN="urxvtc -e"
export LAUNCH_EDITOR="$TERMRUN $EDITOR"
export LAUNCH_FILES="$TERMRUN $FILE_MANAGER"
export LAUNCH_BROWSER=$BROWSER
export LAUNCH_MPLAYER="$TERMRUN $MPLAYER"
export LAUNCH_VPLAYER=$VPLAYER
