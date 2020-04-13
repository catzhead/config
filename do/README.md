# Freqtrade setup from scratch

Connect as root

Retrieve prepare_as_root script:

`wget https://raw.githubusercontent.com/catzhead/config/master/do/prepare_as_root.sh`

Change rights:

`chmod u+x prepare_as_root.sh`

Execute:

`prepare_as_root.sh`

Logout completely and log in as user

Create ssh key for github:

`ssh-keygen -t rsa -b 4096`

Retrieve prepare_as_user script:

`wget https://raw.githubusercontent.com/catzhead/config/master/do/prepare_as_user.sh`

Remember to add the config.json file(s)
