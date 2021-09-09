# Linux configuration

## Troubleshooting

### Hang-up at start (virtual console)

This is a problem with the nouveau driver on linux 5.10. Add `nomodeset` to the
kernel command line:
* in /etc/default/grub, add `nomodeset` to GRUB_CMDLINE_LINUX_DEFAULT
* regenerate the grub config with `grub-mkconfig -o /boot/grub/grub.cfg`
