#!/bin/bash

timezone="$1"
fixtures="$2"
directory="$3"

if ! yum list installed mysql-server >/dev/null 2>&1; then
    echo 'Installing MySQL'
    yum install -y mysql-server mysql-client >/dev/null 2>&1
    
    # Load fixtures
    $directory/mysql-common.sh $timezone $fixtures
fi
