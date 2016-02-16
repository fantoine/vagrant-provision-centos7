#!/bin/bash

if ! yum list installed redis >/dev/null 2>&1; then
    echo 'Installing Redis'
    yum install redis -y --enablerepo=remi,epel >/dev/null 2>&1
    chkconfig redis on

    # Restart Redis
    service redis restart >/dev/null 2>&1
fi
