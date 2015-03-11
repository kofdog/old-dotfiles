# Use this file to set environment variables. It is called from both
# bashrc and xinitrc, and should be sourced by display managers.

# Grab colors and set font
source ~/.palettes/bash-style/base16/eighties
source ~/.palettes/bash-style/base16/colors
source ~/.palettes/bash-style/base16/dark
export COLORS="Base16 Eighties Dark"
export FONT="Source Code Pro Semibold 13"
export FONT_DMENU="Source Code Pro Semibold-11"
export FONT_XFT="Source Code Pro:style=Semibold:size=13"

# Set default applications
export EDITOR="vim"
export FILES=ranger
export BROWSER=firefox
export MAIL=thunderbird
export MPLAYER=ncmpcpp
export VPLAYER=mpv
export LAUNCHER=dmenu-launch

# Set application launchers (for when run outside terminal)
export TERMRUN="urxvtc -e"
export TERMINAL="$TERMRUN fish"
export LAUNCH_FILES="$TERMRUN $FILES"
export LAUNCH_BROWSER=$BROWSER
export LAUNCH_MAIL=$MAIL
export LAUNCH_MPLAYER="$TERMRUN $MPLAYER"
export LAUNCH_VPLAYER=$VPLAYER

# Fix 'less' security
export PAGER=less
unset LESSOPEN
unset LESSPIPE
export LESSSECURE=1

# Fix Opera Flash
export OPERAPLUGINWRAPPER_PRIORITY=0
export OPERA_KEEP_BLOCKED_PLUGIN=1
export GDK_NATIVE_WINDOWS=1
