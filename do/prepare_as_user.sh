#!/bin/bash

# vim

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.vimrc https://raw.githubusercontent.com/catzhead/config/master/arch-xps/home/.vimrc
curl -fLo ~/.vim/colors/catz2term/vim --create-dirs https://raw.githubusercontent.com/catzhead/config/master/arch-xps/home/.vim/colors/catz2term.vim

# freqtrade - ssh key for account must be generated beforehand

cd ~
git clone git@github.com:catzhead/freqtrade.git
cd freqtrade
docker-compose pull
docker-compose build

# python

pip3 install --user virtualenv
python3 -m venv .env
source .env/bin/activate
pip3 install -r scripts/telegram-send-req.txt

echo "config.json has to be added manually"
