#!/bin/bash

github_token="$1"

if [ ! -f /usr/local/bin/composer ] ; then
    echo 'Installing composer'
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1
    chown vagrant:vagrant /usr/local/bin/composer
    
    # Add composer update cron
    echo '0 * * * * /usr/local/bin/composer self-update' >> /etc/crontab

    # Install Github token
    if [ "${github_token}" != "" ]; then
        mkdir -p /etc/.composer
        cp /vagrant/vagrant/data/php/composer-auth.conf /etc/.composer/auth.json
        sed -i -e "s@:github_token:@$github_token@g" /etc/.composer/auth.json
    fi
fi
