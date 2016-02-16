#!/bin/bash

phpName="$1"
timezone="$2"
read -a modules <<< "$3"

if [ ! -f /etc/php.ini ]; then
    echo "Installing PHP and modules"
    yum install -y $phpName ${modules[@]/#/$phpName-} --enablerepo=webtatic >/dev/null 2>&1

    # Use the dev php.ini file
    cp -f /usr/share/doc/$phpName-*/php.ini-development /etc/php.ini

    # Update configuration
    sed -i \
        -e "s/;date\.timezone =.*/date.timezone = $timezone/" \
        -e 's/memory_limit =.*/memory_limit = 1G/' \
        -e 's/error_reporting =.*/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_USER_DEPRECATED \& ~E_STRICT/' \
        /etc/php.ini

    # Chown session folder
    chown -R vagrant:vagrant /var/lib/php/session

    # Update PECL channels
    pecl channel-update pecl.php.net >/dev/null 2>&1

    # Restarting Apache
    service httpd restart >/dev/null 2>&1
fi
