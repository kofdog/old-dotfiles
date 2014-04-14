#!/bin/sh


#--------------------------------------
# X.org
#--------------------------------------

# Load Xresources
xrdb ~/.Xdefaults

# Remove annoying beep
xset b off

# Cursor
xsetroot -cursor_name left_ptr



#--------------------------------------
# Themes
#--------------------------------------

# Wallpaper
feh --bg-fill ~/Pictures/Wallpapers/QwVL3ze\ -\ Imgur.jpg



#--------------------------------------
# Programs
#--------------------------------------

# Defaults
export EDITOR=vim
export BROWSER=google-chrome-stable
export VIEWER=zathura
export VPLAYER=mpv

# Daemons
mpd &



#--------------------------------------
# Window manager
#--------------------------------------

# bspwm
sxhkd &
exec bspwm
