# zen configuration

## networking

Enable the following services:
* `systemd-networkd`
* `systemd-resolved`

By default, systemd-networkd-wait-online waits for all interfaces with a
timeout of 2min, to wait for any interface:

```
systemctl edit --full systemd-networkd-wait-online.service
```

and add "--any" to the ExecStart line:

	ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
