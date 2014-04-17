#!/bin/sh


#--------------------------------------
# X.org
#--------------------------------------

# Load Xresources
xrdb ~/.Xdefaults

# Remove annoying beep
xset b off

# Don't turn off backlight for any reason
xset s off
xset -dpms
xset s noblank

# Set cursor theme
xsetroot -cursor_name left_ptr



#--------------------------------------
# Themes
#--------------------------------------

# Wallpaper
feh --bg-fill ~/Pictures/Wallpapers/QwVL3ze\ -\ Imgur.jpg



#--------------------------------------
# Applications
#--------------------------------------

# Defaults
export TERMINAL=urxvt
export TERMRUN="urxvt -e"
export FM=ranger
export EDITOR=vim
export BROWSER=google-chrome-stable
export VIEWER=zathura
export VPLAYER=mpv
export MPLAYER="ncmpcpp -s media-library"
export MVIZ=viz
export CLOCK=clock

# Daemons
mpd &



#--------------------------------------
# Window manager
#--------------------------------------

# bspwm
sxhkd &
exec bspwm
