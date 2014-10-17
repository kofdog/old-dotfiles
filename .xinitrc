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
mpd &
#start-pulseaudio-x11 &
mpc stop

# File sharing
dropboxd &
CopyAgent &
#google-musicmanager &

# Display
#redshift -l 39.9500:75.1667 &



#--------------------------------------
# Window Manager
#--------------------------------------

session=${1:-spectrwm}

# Only WMs are included here, because DEs should be launched from their
# respective login managers (e.g. gdm, kdm, lightdm).
case $session in
    awesome  ) exec awesome;;
    bspwm    ) exec bspwm;;
    dwm      ) exec dwm-start;;
    i3|i3wm  ) exec i3;;
    openbox  ) exec openbox-session;;
    spectrwm ) compton -b; exec spectrwm;;
    vb       ) VirtualBox -startvm "Windows 8" -fullscreen;;
    xmonad   ) exec xmonad;;
    *        ) exec $1;;
esac
