xrdb ~/.Xresources
xmodmap ~/.config/X11/.remap.internal
xset r rate 400 30
xrandr --output HDMI-0 --mode 3440x1440 --rate 99.98
exec i3
