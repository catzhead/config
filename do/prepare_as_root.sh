#!/bin/bash

# WARNING: execute as root

# access rights

apt-get update
apt-get -qq install sudo
usermod -a -G sudo catzhead

# install utils

apt-get -qq install vim curl git

# configure ssh

if [ -e ~/.ssh/authorized_keys ]
then
  mkdir /home/catzhead/.ssh
  cp /root/.ssh/authorized_keys /home/catzhead/.ssh
  chown -R catzhead /home/catzhead/.ssh
else
  echo "couldn't find authorized_keys, skipping"
fi

# small stuff

echo TERM=xterm >> ~/.bashrc
echo alias vi=\'vim\' >> ~/.bashrc
echo TERM=xterm >> /home/catzhead/.bashrc
echo alias vi=\'vim\' >> ~/.bashrc
