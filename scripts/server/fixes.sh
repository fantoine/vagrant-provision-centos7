#!/bin/bash

# Fixing slow curl requests (ipv6 resolving timeouts causing issue)
# See: https://github.com/mitchellh/vagrant/issues/1172
if [ ! "$(grep single-request-reopen /etc/resolv.conf)" ]; then
    echo "Fixing slow curl requests"
    echo 'options single-request-reopen' >> /etc/resolv.conf
    systemclt restart network >/dev/null 2>&1
fi

# Fix GRUB timeout
if ! grep -q "vagrant-grub" /boot/grub2/grub.cfg; then
    echo "Fixing grub start timeout"
    sed -i 's/timeout=.*/timeout=0 # vagrant-grub/g' /boot/grub2/grub.cfg
fi
