#!/bin/bash

# Installing sudoers
if [ ! -f /etc/sudoers.d/vagrant ]; then
    echo "Installing sudoers"
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
fi
