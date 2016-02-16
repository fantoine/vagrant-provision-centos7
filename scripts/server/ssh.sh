#!/bin/bash

ssh_key="$1"
read -a ssh_hosts <<< "$2"

comment='#Vagrant'
authorized_keys='/home/vagrant/.ssh/authorized_keys'
known_hosts='/home/vagrant/.ssh/known_hosts'

# Make sure to have ssh files
mkdir -p ~/.ssh
touch $authorized_keys
touch $known_hosts
chown -R vagrant:vagrant ~/.ssh

if ! grep -q $comment $authorized_keys; then
    echo 'Installing SSH keys'
    echo $comment >> $authorized_keys
    cat $ssh_key >> $authorized_keys
fi

if ! grep -q $comment $known_hosts; then
    echo 'Installing known hosts'
    echo $comment >> $known_hosts
    for i in ${ssh_hosts[@]}
    do
        ssh-keyscan -H $i >> $known_hosts >/dev/null 2>&1
    done
fi
