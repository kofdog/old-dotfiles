Numix-Blue is a slight tweak to the awesome Numix theme, replacing orange (#d64937) with blue (#4b5871).

Numix is a modern flat theme with a combination of light and dark elements. It supports Gnome, Unity, XFCE and Openbox.

### Manual installation

Extract the zip file to the themes directory i.e. `/usr/share/themes/`

To set the theme in Gnome, run the following commands in Terminal,

```
gsettings set org.gnome.desktop.interface gtk-theme "Numix-Blue"
gsettings set org.gnome.desktop.wm.preferences theme "Numix-Blue"
```

To set the theme in Xfce, run the following commands in Terminal,

```
xfconf-query -c xsettings -p /Net/ThemeName -s "Numix-Blue"
xfconf-query -c xfwm4 -p /general/theme -s "Numix-Blue"
```

### Requirements

GTK+ 3.6 or above

Murrine theme engine

### Code and license

Report bugs or contribute to the original project at [GitHub](https://github.com/shimmerproject/Numix)

License: GPL-3.0+
