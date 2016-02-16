#!/bin/bash

domain="$1"
read -a domains <<< "$2"
ssl="$3"
conftpl="$4"
confssltpl="$5"

conf='/etc/nginx/conf.d/vagrant.conf'
sslconf='/etc/nginx/conf.d/vagrant.ssl.conf'

if ! yum list installed nginx18 >/dev/null 2>&1; then
    echo 'Installing Nginx'
    yum install -y nginx18 --enablerepo=webtatic >/dev/null 2>&1
    chkconfig nginx on >/dev/null 2>&1
fi

function nginx_conf {
    template="$1"
    target="$2"
    domain="$3"

    # Add configuration
    cp $template $target

    # Prepare aliases
    declare -a aliases
    for sub in "${domains[@]}"
    do
        aliases=(${aliases[@]} "$sub.$domain")
    done

    # Inject variables
    alias="${aliases[@]}"
    sed -i \
        -e "s@:domain:@$domain@g" \
        -e "s@:domains:@$alias@g" \
        $target
}

if [ ! -f $conf ] || [[ "$ssl" == "true" && (! -f $sslconf) ]]; then
    # Add default configuration
    echo 'Adding default server'
    nginx_conf $conftpl $conf $domain

    # Add ssl configuration
    if [ "$ssl" == "true" ]; then
        echo 'Adding SSL server'
        nginx_conf $confssltpl $sslconf $domain
    fi

    # Restarting httpd service
    service nginx restart >/dev/null 2>&1
fi
