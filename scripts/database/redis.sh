#!/bin/bash

if ! yum list installed redis >/dev/null 2>&1; then
    echo 'Installing Redis'
    yum install redis -y --enablerepo=remi,epel >/dev/null 2>&1
    systemctl enable redis

    # Restart Redis
    systemclt restart redis >/dev/null 2>&1
fi
