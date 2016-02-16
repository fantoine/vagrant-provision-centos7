#!/bin/bash

if [ ! -f /usr/local/bin/phpunit ] ; then
    echo 'Installing phpunit'
    wget -O /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar >/dev/null 2>&1
    chmod +x /usr/local/bin/phpunit
    chown vagrant:vagrant /usr/local/bin/phpunit

    # Add phpunit update cron
    echo '0 * * * * /usr/local/bin/phpunit --self-update' >> /etc/crontab
fi
