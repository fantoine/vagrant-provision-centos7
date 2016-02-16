#!/bin/bash

fixtures="$1"
phpenabled="$2"
driverversion="1.6.8"

if ! yum list installed mongodb-org >/dev/null 2>&1; then
    echo 'Installing MongoDB'

    cat > /etc/yum.repos.d/mongodb-org-3.0.repo <<- CONTENT
[mongodb-org-3.0]
name=MongoDB Repository
baseurl=http://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=1
CONTENT
    yum install -y mongodb-org >/dev/null 2>&1
    chkconfig mongod on >/dev/null 2>&1

    # Restart MongoDB
    service mongod restart >/dev/null 2>&1
fi

if [ "$phpenabled" == true ] && [ ! "$(php -m | grep mongo)" ]; then
    echo 'Installing MongoDB PHP driver'

    mkdir -p /tmp/mongo-php

    # Download driver
    wget -O /tmp/mongo-php/mongo-php-driver.zip "https://github.com/mongodb/mongo-php-driver/archive/${driverversion}.zip" >/dev/null 2>&1
    pushd /tmp/mongo-php/ >/dev/null 2>&1
    unzip mongo-php-driver.zip >/dev/null 2>&1

    # Compile & Install
    pushd "/tmp/mongo-php/mongo-php-driver-${driverversion}" >/dev/null 2>&1
    phpize >/dev/null 2>&1
    ./configure >/dev/null 2>&1
    make all >/dev/null 2>&1
    make install >/dev/null 2>&1
    popd >/dev/null 2>&1
    popd >/dev/null 2>&1

    # Clean temporary files
    rm -rf /tmp/mongo-php

    # Enable module
    echo '; Enable mongo extension module' > /etc/php.d/mongo.ini
    echo 'extension=mongo.so' >> /etc/php.d/mongo.ini

    # Restart Apache
    service httpd restart >/dev/null 2>&1
fi

# Load fixtures
if [ "$fixtures" != "" ] && [ -f $fixtures ]; then
    echo 'Loading fixtures'
    mongo "$fixtures" >/dev/null 2>&1
fi
