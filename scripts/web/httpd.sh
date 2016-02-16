#!/bin/bash

domain="$1"
read -a domains <<< "$2"
read -a webroots <<< "$3"
ssl="$4"
conftpl="$5"
confssltpl="$6"

conf='/etc/httpd/conf.d/vagrant.conf'
sslconf='/etc/httpd/conf.d/vagrant.ssl.conf'

if ! yum list installed httpd >/dev/null 2>&1; then
    echo 'Installing Apache'
    yum install -y httpd mod_ssl >/dev/null 2>&1
    chkconfig httpd on >/dev/null 2>&1

    # Add upstart script
    cp /vagrant/vagrant/data/web/init-httpd.conf /etc/init/

    # Update default httpd configuration
    sed -i \
        -e 's/User .*/User vagrant/' \
        -e 's/Group .*/Group vagrant/' \
        -e 's/#EnableSendfile .*/EnableSendfile off/' \
        /etc/httpd/conf/httpd.conf
fi

function apache2_conf {
    template="$1"
    target="$2"
    webroot="$3"
    domain="$4"

    # Add configuration
    cp $template $target

    # Inject variables
    sed -i \
        -e "s@:domain:@$domain@g" \
        -e "s@:webroot:@$webroot@g" \
        $target
    for sub in "${domains[@]}"
    do
        sed -i -e "/ServerName.*/a    ServerAlias $sub.$domain" $target
    done
}

if [ ! -f $conf ] || [[ "$ssl" == "true" && (! -f $sslconf) ]]; then
    for i in ${webroots[@]}
    do
        if [ -d $i ]
        then
            echo 'Mounting webroot on' $i
            webroot=$i
            break
        fi
    done

    # Add default configuration
    echo 'Adding default Virtualhost'
    apache2_conf $conftpl $conf $webroot $domain
    sed -i -e 's/Listen 80/#Listen 80' /etc/httpd/conf/httpd.conf

    # Add ssl configuration
    if [ "$ssl" == "true" ]; then
        echo 'Adding SSL Virtualhost'
        apache2_conf $confssltpl $sslconf $webroot $domain
        if ! grep -q "disable_virtualhost_hack" /etc/httpd/conf.d/ssl.conf; then
            sed -i \
                -e 's/Listen 443/#Listen 443' \
                -e '/<VirtualHost _default_:443>/i <IfModule disable_virtualhost_hack.c>' \
                -e '/<\/VirtualHost>/a <\/IfModule>' \
                /etc/httpd/conf.d/ssl.conf
        fi
    fi

    # Restarting httpd service
    service httpd restart >/dev/null 2>&1
fi
