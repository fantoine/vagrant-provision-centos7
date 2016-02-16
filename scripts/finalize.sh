#!/bin/bash

# Installing login 'cd'
cdVagrant='cd /vagrant'
if ! grep -q "$cdVagrant" /home/vagrant/.bashrc ; then
    echo 'Setup home directory'
    echo '# Go to vagrant' >> /home/vagrant/.bashrc
    echo "$cdVagrant" >> /home/vagrant/.bashrc
fi
