# Arch

## Utils

journalctl

# X11

## Installation

```
pacman -S xorg-server xorg-xinit
pacman -S pango ttf-dejavu
pacman -S i3
```

## Launch

To launch startx with a special wm (ignoring .xinitc)
```
startx /bin/i3
```

## Configuration

### Devices

```
libinput list-devices
```

### Touchpad

Enable touch-to-click, create /etc/X11/xorg.conf.d/30-touchpad.conf:
```
Section "InputClass"
	Identifier "touchpad"
	Driver "libinput"
	MatchIsTouchpad "on"
	Option "Tapping" "on"
	Option "TappingButtponMap" "lmr"
	Option "NaturalScrolling" "true"
EndSection
```

### Keyboard rate

```
pacman -S xorg-xset
xset r rate 300 30
```

To keep it set, add it to ~/.xinitrc

### Brightness control

```
pacman -S light
```

In i3 config:
```
bindsym XF86MonBrightnessUp exec light -A 2
bindsym XF86MonBrightnessDown exec light -U 2
```

### Audio controls

In i3 config:
```
bindsym XF86AudioMute exec pulsemixer --toggle-mute
bindsym XF86AudioLowerVolume exec pulsemixer --change-volume -5
bindsym XF86AudioRaiseVolume exec pulsemixer --change-volume +5
```

# i3

Use the Windows key: set $mod Mod4

# Power management

```
pacman -S powertop
```

In "tunables", each item can be toggled

# Audio

```
pacman -S alsautils pulseaudio pulseaudio-alsa
pip install pulsemixer
```

# Bluetooth

```
rfkill list
systemctl status bluetooth
systemctl start bluetooth
```

## Headset

```
pacman -S pulseaudio-bluetooth
```

Add the following to /etc/bluetooth/main.conf:
```
Enable=Source,Sink,Media,Socket
```

Don't know if it is necessary, but add user to groups audio and lp

Also, don't know if it is necessary:
```
sudo useradd --system -g pulse -G audio,lp --home-dir /var/run/pulse pulse
```

To connect:
```
bluetoothctl
power on
scan on
trust xx:xx:xx..
connect xx:xx:xx..
scan off
```

# Log files

* systemctl --failed
* journalctl
* xorg: ~/.local/share/xorg/Xorg.<display>.log
