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
#xinput set-prop 12 "Device Enabled" 0



#--------------------------------------
# Themes
#--------------------------------------

# Set wallpaper
sh ~/.fehbg &



#--------------------------------------
# Daemons
#--------------------------------------

# Terminal
urxvtd &

# Audio
start-pulseaudio-x11 &
mpd &
ncmpcpp stop

# File sharing
dropboxd &
CopyAgent &
#google-musicmanager &

# Hide cursor
unclutter &

# Display
#redshift -l 39.9500:75.1667 &



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
export MPLAYER=ncmpcpp
export MVIZ=viz
export CLOCK=clock

# Paths
export GOPATH=~/.gopath



#--------------------------------------
# Window Manager / Desktop Environment
#--------------------------------------

session=${1:-dwm}

case $session in
    awesome  ) exec awesome;;
    bspwm    ) exec bspwm;;
    cinnamon ) exec cinnamon-session;;
    dwm      ) exec dwm-start;;
    gnome    ) exec gnome-session;;
    i3|i3wm  ) exec i3;;
    kde4     ) exec startkde;;
    kde      ) exec /opt/kf5/bin/startkde;;
    lxde     ) exec startlxde;;
    openbox  ) exec openbox-session;;
    unity    ) exec unity;;
    vb       ) VirtualBox -startvm "Windows 8" -fullscreen;;
    xfce     ) exec startxfce4;;
    xmonad   ) exec xmonad;;
    *        ) exec $1;;
esac
