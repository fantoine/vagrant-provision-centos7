#!/bin/bash

serverid="$1"
servertoken="$2"

if ! yum list installed blackfire-agent >/dev/null 2>&1; then
    echo 'Installing blackfire'
    
    # Install blackfire tools
    yum install -y pygpgme >/dev/null 2>&1
    wget -O /etc/yum.repos.d/blackfire.repo "http://packages.blackfire.io/fedora/blackfire.repo" >/dev/null 2>&1
    yum install -y blackfire-agent blackfire-php >/dev/null 2>&1

    # Update configuration
    sed -i \
        -e "s/server-id=.*/server-id=$serverid/" \
        -e "s/server-token=.*/server-token=$servertoken/" \
        /etc/blackfire/agent
    
    # Restart service
    service blackfire-agent restart >/dev/null 2>&1
fi
