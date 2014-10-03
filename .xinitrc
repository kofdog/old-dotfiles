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
start-pulseaudio-x11 &
mpc stop

# File sharing
dropboxd &
CopyAgent &
#google-musicmanager &

# Display
#redshift -l 39.9500:75.1667 &



#--------------------------------------
# System Variables
#--------------------------------------

# Default applications
export TERMINAL=urxvtc
export FM=ranger
export EDITOR=vim
export BROWSER=firefox
export MAIL=thunderbird
export MPLAYER=ncmpcpp
export VPLAYER=mpv
export VIEWER=zathura
export CLOCK=clock

# Application launchers (may need to be run in terminal)
export TERMRUN="urxvtc -e"
export LAUNCH_TERMINAL=${TERMINAL}
export LAUNCH_FM="${TERMRUN} ${FM}"
export LAUNCH_EDITOR="${TERMRUN} ${EDITOR}"
export LAUNCH_BROWSER=${BROWSER}
export LAUNCH_MAIL=${MAIL}
export LAUNCH_MPLAYER="${TERMRUN} ${MPLAYER}"
export LAUNCH_VPLAYER=${VPLAYER}
export LAUNCH_VIEWER=${VIEWER}
export LAUNCH_CLOCK="${TERMRUN} ${CLOCK}"



#--------------------------------------
# Window Manager / Desktop Environment
#--------------------------------------

session=${1:-bspwm}

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
    spectrwm ) exec spectrwm;;
    unity    ) exec unity;;
    vb       ) VirtualBox -startvm "Windows 8" -fullscreen;;
    xfce     ) exec startxfce4;;
    xmonad   ) exec xmonad;;
    *        ) exec $1;;
esac
