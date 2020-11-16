# zen server configuration

## Thermals

Install lm_sensors and asus-wmi-sensors-dkms-git

## Docker

Copy etc/systemd/system/docker.service.d/docker.conf

Warning: iptables needs to be true for the containers to access the network

## Networking

Configure the resolv.conf file in /etc for the DNS to work.

Arch linux uses systemd-networkd to manage the network connection by default,
the configuration is in etc/systemd/network for wired systems. Then the
service needs to be enabled/started by systemd.
