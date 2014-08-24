#!/bin/sh



#--------------------------------------
# X.org
#--------------------------------------

# Load from global xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Load Xresources
xrdb -merge ~/.Xresources

# Remove annoying beep
xset b off

# Don't turn off backlight for any reason
xset s off
xset -dpms
xset s noblank

# Set cursor theme
xsetroot -cursor_name left_ptr

# Disable touchpad
xinput set-prop 12 "Device Enabled" 0



#--------------------------------------
# Themes
#--------------------------------------

# Set wallpaper
feh --bg-fill ~/Pictures/Yosemite.jpg



#--------------------------------------
# Applications
#--------------------------------------

# Run startup scripts
~/.bin/fix-file-sharing

# Start daemons
mpd &
urxvtd &
dropboxd &
CopyAgent &



#--------------------------------------
# System Variables
#--------------------------------------

# Default applications
export TERMINAL=urxvtc
export TERMRUN="urxvtc -e"
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

session=${1:-bspwm}

case $session in
    awesome  ) exec awesome;;
    bspwm    ) exec bspwm;;
    cinnamon ) exec cinnamon-session;;
    dwm      ) exec dwm;;
    gnome    ) exec gnome-session;;
    i3|i3wm  ) exec i3;;
    kde      ) exec startkde;;
    lxde     ) exec startlxde;;
    openbox  ) exec openbox-session;;
    unity    ) exec unity;;
    vb       ) VirtualBox -startvm "Windows 8" -fullscreen;;
    xfce     ) exec startxfce4;;
    xmonad   ) exec xmonad;;
    *        ) exec $1;;
esac
