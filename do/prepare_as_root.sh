#!/bin/bash

# WARNING: execute as root

# access rights

apt-get -qq update
apt-get -qq install sudo
usermod -aG sudo catzhead

# docker (from DigitalOcean blog)

apt-get -qq install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get -qq update
apt-cache policy docker-ce
apt-get -qq install docker-ce
usermod -aG docker catzhead

# docker-compose

curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

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
