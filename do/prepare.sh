#!/bin/bash

# WARNING: execute as root

# access rights

apt-get update
apt-get --assume-yes install sudo
usermod -a -G sudo catzhead

# install utils

apt-get --assume-yes install vim

# configure ssh

mkdir /home/catzhead/.ssh
cp /root/.ssh/authorized_keys /home/catzhead/.ssh
chown -R catzhead /home/catzhead/.ssh

# small stuff

echo TERM=xterm >> ~/.bashrc
echo alias vi=\'vim\' >> ~/.bashrc
echo TERM=xterm >> /home/catzhead/.bashrc
echo alias vi=\'vim\' >> ~/.bashrc
