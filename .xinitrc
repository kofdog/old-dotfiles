#!/bin/sh



#--------------------------------------
# X.org
#--------------------------------------

# Load Xresources
xrdb ~/.Xresources

# Load keybindings
xbindkeys



#--------------------------------------
# System Variables
#--------------------------------------

# Default applications
export TERMINAL=urxvt
export TERMRUN="urxvt -e"
export FM=ranger
export EDITOR=vim
export BROWSER=firefox
export VIEWER=zathura
export VPLAYER=mpv
export MPLAYER="ncmpcpp -s media-library"
export MVIZ=viz
export CLOCK=clock

# Paths
export GOPATH=~/.gopath



#--------------------------------------
# Window Manager / Desktop Environment
#--------------------------------------

case $WM in
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
    vb)
        VirtualBox -startvm "Windows 8" -fullscreen
        ;;
    xfce)
        exec startxfce4
        ;;
    lxde)
        exec startlxde
        ;;
    openbox)
        exec openbox-session
        ;;
    i3)
        exec i3
        ;;
    *)
        sxhkd &
        exec bspwm
        ;;
esac
