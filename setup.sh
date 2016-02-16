#!/bin/bash

# Get provisionning directory
dir=/vagrant/vagrant
scripts=$dir/scripts

# Load configuration
. "$1"

# Server configuration
if [ "$2" == "server" ]; then
    $scripts/server/user.sh
    $scripts/server/repos.sh
    $scripts/server/update.sh
    $scripts/server/start-stop-daemon.sh
    $scripts/server/ssh.sh "${CONFIG['server:ssh_key']}" "${CONFIG['server:known_hosts']}"
    $scripts/server/ntp.sh "${CONFIG['server:timezone']}"
    $scripts/server/fixes.sh
fi

# Installation
if [ "$2" == "install" ]; then
    # Get script arguments
    domain="$3"
    domains="$4"

    # Web server configuration
    if [ "${CONFIG['web:ssl']}" == true ]; then
        $scripts/web/ssl.sh "$domain"
    fi
    if [ "${CONFIG['web:httpd:enabled']}" == true ]; then
        $scripts/web/httpd.sh "$domain" "$domains" "${CONFIG['web:webroots']}" "${CONFIG['web:ssl']}" "${CONFIG['web:httpd:conf']}" "${CONFIG['web:httpd:confssl']}"
    fi
    if [ "${CONFIG['web:nginx:enabled']}" == true ]; then
        $scripts/web/nginx.sh "$domain" "$domains" "${CONFIG['web:ssl']}" "${CONFIG['web:nginx:conf']}" "${CONFIG['web:nginx:confssl']}"
    fi

    # PHP configuration
    if [ "${CONFIG['php:enabled']}" == true ]; then
        if [ -f "$scripts/php/php-${CONFIG['php:version']}.sh" ]; then
            $scripts/php/php-${CONFIG['php:version']}.sh "${CONFIG['server:timezone']}" "${CONFIG['php:modules']}" "$scripts/php"
        fi
        if [ "${CONFIG['php:composer:enabled']}" == true ]; then
            $scripts/php/composer.sh "${CONFIG['php:composer:github_token']}"
        fi
        if [ "${CONFIG['php:phpunit']}" == true ]; then
            $scripts/php/phpunit.sh
        fi
        if [ "${CONFIG['php:blackfire:enabled']}" == true ]; then
            $scripts/php/blackfire.sh "${CONFIG['php:blackfire:server_id']}" "${CONFIG['php:blackfire:server_token']}"
        fi
        if [ "${CONFIG['php:hhvm:enabled']}" == true ]; then
            $scripts/php/hhvm.sh "${CONFIG['php:hhvm:composer']}"
        fi
    fi

    # Database configuration
    if [ "${CONFIG['database:sql:enabled']}" == true ] && [ -f "$scripts/database/sql/${CONFIG['database:sql:mode']}.sh" ]; then
        $scripts/database/sql/${CONFIG['database:sql:mode']}.sh "${CONFIG['server:timezone']}" "${CONFIG['database:sql:fixtures']}" "$scripts/database/sql"
    fi
    if [ "${CONFIG['database:redis:enabled']}" == true ]; then
        $scripts/database/redis.sh
    fi
    if [ "${CONFIG['database:mongodb:enabled']}" == true ]; then
        $scripts/database/mongodb.sh "${CONFIG['database:mongodb:fixtures']}" "${CONFIG['php:enabled']}"
    fi

    # Tools configuration
    if [ "${CONFIG['phpmyadmin:enabled']}" == true ]; then
        $scripts/tools/phpmyadmin.sh "${CONFIG['phpmyadmin:version']}"
    fi
    if [ "${CONFIG['nodejs:enabled']}" == true ]; then
        $scripts/tools/nodejs.sh "${CONFIG['nodejs:libraries']}"
    fi
    if [ "${CONFIG['ruby:enabled']}" == true ]; then
        $scripts/tools/ruby.sh "${CONFIG['ruby:gems']}"
    fi
    if [ "${CONFIG['python:enabled']}" == true ]; then
        $scripts/tools/python.sh "${CONFIG['python:version']}" "${CONFIG['python:pip']}"
    fi
    if [ "${CONFIG['zeromq:enabled']}" == true ]; then
        $scripts/tools/zeromq.sh "${CONFIG['php:enabled']}"
    fi

    # Symfony configuration
    if [ "${CONFIG['symfony:installer']}" == true ]; then
        $scripts/symfony/installer.sh
    fi
    if [ "${CONFIG['symfony:completion']}" == true ]; then
        $scripts/symfony/completion.sh
    fi
    if [ "${CONFIG['symfony:twig']}" == true ]; then
        $scripts/symfony/twig.sh
    fi

    # Search engine configuration
    if [ "${CONFIG['search:enabled']}" == true ] && [ -f "$scripts/search/${CONFIG['search:mode']}.sh" ]; then
        $scripts/search/${CONFIG['search:mode']}.sh
    fi

    # Finalize
    $scripts/finalize.sh
fi
