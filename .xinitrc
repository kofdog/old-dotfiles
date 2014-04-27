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
# Paths
#--------------------------------------

# Go programming language
export GOPATH=~/.gopath



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
dropboxd &
CopyAgent &



#--------------------------------------
# Window Manager / Desktop Environment
#--------------------------------------

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Default
session=${1: -bspwm}

# Select
case $session in
    bspwm) 
        sxhkd &
        exec bspwm
        ;;
    gnome)
        exec gnome-session
        ;;
    kde)
        exec startkde
        ;;
    *)
        exec $1
        ;;
esac
