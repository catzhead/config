#!/bin/bash

# vim

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.vimrc https://raw.githubusercontent.com/catzhead/config/master/arch-xps/home/.vimrc

# freqtrade - ssh key for account must be generated beforehand

cd ~
git clone git@github.com:catzhead/freqtrade.git
cd freqtrade
docker-compose pull
docker-compose build
