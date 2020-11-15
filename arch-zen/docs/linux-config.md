# zen server configuration

## Networking

Configure the resolv.conf file in /etc for the DNS to work.

Arch linux uses systemd-networkd to manage the network connection by default,
the configuration is in etc/systemd/network for wired systems. Then the
service needs to be enabled/started by systemd.
