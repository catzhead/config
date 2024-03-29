# Arch

## pacman

update all

```
pacman -Syu
```

force reinstall all packages

```
for i in `pacman -Qq` ; do sudo pacman -S --noconfirm $1 ; done
```

## Filesystems

list all available partitions for mounting:

```
fdisk -l
```

check type of fs:

```
sudo file -sL /dev/x
```

curses-style fdisk:

```
cfdisk
```

## systemd

When a service is called x@.service in /etc/systemd/system, it works for any
service x@y.service. To lock the session on systemctl suspend, the service
has to be enabled:

```
sudo systemctl enable suspend@catzhead
```

## Networking

```
nmcli device wifi list
nmcli device wifi connect <SSID> password <password>
```

If problem during the connection (e.g. strange characters in the passwd):
/etc/NetworkManager/system-connections

## Samba

Install cifs

```
sudo mount -t cifs //ds414/video1 /mnt/smb\
  -ouid=catzhead,gid=catzhead,username=catzhead
```

## Sleep mode

The default sleep mode consumes too much battery overnight (~10%), use S3
instead (resume is for hibernation, maybe not necessary in this case) by
adding the following line in /etc/default/grub and regenerating the grub
config:

GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet mem_sleep_default=deep resume=UUID=75ed788c-30fb-4674-baed-ce4b28bf51f8"

## GRUB

When creating a new linux partition, the bootloader needs to be reinstalled.
The arch guide is ok, os-prober doesn't work with arch so the simple solution
is to manually add the old menuentry in the /etc/grub.d/40_custom file and
regenerate the grub config:

'''
grub-mkconfig -o /boot/grub/grub.cfg
'''

# X11

## Installation

```
pacman -S xorg-server xorg-xinit
pacman -S pango ttf-dejavu noto-fonts ttf-inconsolata
pacman -S adobe-source-han-sans-jp-fonts
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

To check the brightness:
```
cat /sys/class/backlight/intel_backlight/brightness
```

To change the brightness manually:
```
echo 1000 > /sys/class/backlight/intel_backlight/brightness
```

If permission denied, create /etc/udev/rules.d/backlight.rules:
```
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
```

And add user to 'video' group

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

### Multiple monitors

```
xrandr --output DP2 --auto --above eDP1
```

# Wayland

## Hardware acceleration

Install intel-media-driver (NOT libva-intel-driver). To check that it's
working, use vainfor from libva-utils and intel_gpu_top from intel_gpu_tools.

Check [arch wiki](https://wiki.archlinux.org/title/Hardware_video_acceleration)

## Firefox

```
MOZ_ENABLE_WAYLAND=1 firefox
```

## Chromium

Screen sharing, install:
```
pipewire
xdg-desktop-portal
xdg-desktop-portal-wlr
slurp
wofi
bemenu
```

Enable flag "WebRTC PipeWire support"

# i3

Use the Windows key: set $mod Mod4

# Power management

```
pacman -S powertop
```

In "tunables", each item can be toggled

## Sleep

Seems that there is a problem with sleep mode on XPS, add the following parameter to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub:

```
mem_sleep_default=deep
```

like:

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet mem_sleep_default=deep resume=PARTUUID=bbba9765-4af4-cd44-9d14-89cbd847476b"
```

and regenerate the config:

```
grub-mkconfig -o /boot/grub/grub.cfg
```

## Fan control

Install libsmbios and set the thermal mode:

```
smbios-thermal-ctl --set-thermal-mode=Quiet
```

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

## Reconnect keyboard

'''
systemctl start bluetooth
bluetoothctl
power on
'''

# Log files

* systemctl --failed
* journalctl
* xorg: ~/.local/share/xorg/Xorg.<display>.log

# Powerline

```
pacman -S powerline powerline-fonts
git clone git@github.com:powerline/fonts.git
cd fonts
install
```

In urxvt, use patched font:
```
URxvt.font:	 xft:Inconsolata\ for\ powerline:pixelsize=17
```

Warning: documentation says that configuration files are merged, it does not seem to be the case in arch...

set XDG_CONFIG_HOME to ~/.config

Retrieve /usr/lib/python3.7/site-packages/powerline/config_files into ~/.config/powerline
Change the shell theme to default_leftonly (bash does not support right-hand prompt)

To configure cwd, copy /usr/lib/python3.7/site-packages/powerline/config_files/themes/shell/__main__.json into ~/.config/powerline/themes/shell and change:

```
"cwd": {
  "args": {
    "dir_limit_depth": 1,
    "ellipsis": null
   }
}
```

To take the changes into account:

```
powerline-daemon --replace
```

# Misc

## Problems with characters in ssh

In the remote environment, set TERM to rxvt-256color

## K8s

scp sa@157.230.26.123:~/.kube/config kubeconfig
export KUBECONFIG=${PWD}/kubeconfig

