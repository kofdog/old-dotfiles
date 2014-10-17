#!/bin/sh

# This file will only be run when directly calling xinit or startx, NOT
# when using a display manager. Use it to set up anything specific to
# basic window managers, and use .xprofile for more global setup.


#--------------------------------------
# X.org
#--------------------------------------

# Source system-wide xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Source xprofile
[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

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
# Window Manager
#--------------------------------------

session=${1:-spectrwm}

# Only WMs are included here, because DEs should be launched from their
# respective display managers (e.g. gdm, kdm, lightdm).
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
