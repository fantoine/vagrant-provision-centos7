#!/bin/bash

completion='/home/vagrant/symfony2-autocomplete.bash'

if [ ! -f $completion ]; then
    echo 'Installing Symfony console completion'
    wget -O $completion https://raw.githubusercontent.com/KnpLabs/symfony2-autocomplete/master/symfony2-autocomplete.bash >/dev/null 2>&1
    chmod a+x "$completion"
    chown vagrant:vagrant "$completion"

    echo '# Symfony2 completion' >> /home/vagrant/.bashrc
    echo "source $completion" >> /home/vagrant/.bashrc
fi
