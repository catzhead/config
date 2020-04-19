# Freqtrade setup from scratch

Connect as root

Retrieve prepare_as_root script:

`wget https://raw.githubusercontent.com/catzhead/config/master/do/prepare_as_root.sh`

Change rights:

`chmod u+x prepare_as_root.sh`

Execute:

`prepare_as_root.sh`

Logout completely and log in as user

Create ssh key for github and upload the public key:

`ssh-keygen -t rsa -b 4096`

Retrieve prepare_as_user script:

`wget https://raw.githubusercontent.com/catzhead/config/master/do/prepare_as_user.sh`

Remember to add the config.json file(s)

Warning: the user script leaves the user in the virtualenv
