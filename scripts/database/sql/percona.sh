#!/bin/bash

timezone="$1"
fixtures="$2"
directory="$3"

if ! yum list installed Percona-Server-server-56 >/dev/null 2>&1; then
    echo 'Installing Percona'
    yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm >/dev/null 2>&1
    yum install -y Percona-Server-client-56 Percona-Server-server-56 >/dev/null 2>&1

    # Load fixtures
    $directory/mysql-common.sh $timezone $fixtures
fi
