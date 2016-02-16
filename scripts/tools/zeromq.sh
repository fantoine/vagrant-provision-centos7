#!/bin/bash

phpenabled="$1"

if ! yum list installed zeromq >/dev/null 2>&1; then
    echo 'Installing ZeroMQ'

        cat > /etc/yum.repos.d/fengshuo.zeromq.repo <<- CONTENT
[home_fengshuo_zeromq]
name=The latest stable of zeromq builds (CentOS_CentOS-6)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-6/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-6/repodata/repomd.xml.key
enabled=1
CONTENT

    yum install -y zeromq zeromq-devel >/dev/null 2>&1
fi

if [ "$phpenabled" == true ] && [ ! "$(php -m | grep zmq)" ]; then
    echo 'Installing ZeroMQ PHP driver'

    # Install module
    yes '' | pecl install zmq-beta >/dev/null 2>&1

    # Enable module
    echo '; Enable zmq extension module' > /etc/php.d/zmq.ini
    echo 'extension=zmq.so' >> /etc/php.d/zmq.ini

    # Restart Apache
    service httpd restart >/dev/null 2>&1
fi
