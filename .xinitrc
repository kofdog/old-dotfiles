#!/bin/sh

# Use this file to configure an X session. It is called by xinit and
# startx, but not from display managers.

# Source system-wide xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Source autostart
[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

# Source environment variables
[ -f ~/.profile ] && source ~/.profile

# Modify keyboard layout
setxkbmap -option ctrl:swapcaps -option altwin:swap_alt_win

# Remove annoying beep
xset b off

# Don't turn off backlight for any reason
xset s off
xset -dpms
xset s noblank

# Set cursor theme
xsetroot -cursor_name left_ptr

# Set wallpaper
sh ~/.fehbg &

# Set default session
session=${1:-bspwm}

# Only WMs are included here, because DEs should be launched from their
# respective display managers (e.g. gdm, kdm, lightdm)
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
