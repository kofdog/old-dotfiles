# Use this file to set environment variables. It is called from both
# bashrc and xinitrc, and should be sourced by display managers.

# Grab colors and set font
source ~/.palettes/bash-style/base16/eighties
source ~/.palettes/bash-style/base16/colors
source ~/.palettes/bash-style/base16/dark
export COLORS="Base16 Eighties Dark"
export FONT="Source Code Pro 14"
export FONT_DMENU="Source Code Pro-14"
export FONT_LEMONBAR="Source Code Pro-14"
export OFFSET_LEMONBAR=0
export FONT_LEMONBAR_ICONS="FontAwesome-14"
export OFFSET_LEMONBAR_ICONS=-6
export FONT_LEMONBAR_WORKSPACES="FontAwesome-14"
export OFFSET_LEMONBAR_WORKSPACES=-6
export FONT_XFT="Source Code Pro:style=Regular:size=14"

# Set default applications
export ALT_BROWSER=firefox
export BROWSER=chromium
export EDITOR=vim
export FILES=ranger
export LAUNCHER=dmenu-launch
export MAIL=mutt
export MPLAYER=ncmpcpp
export READER=zathura
export VIEWER=feh
export VPLAYER=mpv

# Set application launchers (for when run outside terminal)
export TERMINAL=urxvtc
export TERMRUN="$TERMINAL -e"
export LAUNCH_FILES="$TERMRUN $FILES"
export LAUNCH_BROWSER=$BROWSER
export LAUNCH_ALT_BROWSER=$ALT_BROWSER
export LAUNCH_MAIL="$TERMRUN $MAIL"
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
