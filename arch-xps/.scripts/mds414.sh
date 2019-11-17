#!/bin/bash

# mount as samba
# sudo mount -t cifs //ds414/$1 /mnt/net -ouid=catzhead,gid=catzhead,username=catzhead

# mount as nfs
sudo mount ds414:/ /mnt/net
