#!/bin/bash

domain="$1"

sslpath="/etc/ssl/${domain}"
sslfile="${sslpath}/${domain}"

if [ ! -f "${sslfile}.key" ]; then
    echo 'Generating SSL certificate'
    mkdir -p "$sslpath"
    openssl genrsa -out "${sslfile}.key" 2048 >/dev/null 2>&1
    openssl req \
        -new -nodes \
        -subj "/C=US/ST=Vagrant/L=Vagrant/O=Vagrant/OU=Dev/CN=*.${domain}/emailAddress=vagrant@${domain}" \
        -key "${sslfile}.key" -out "${sslfile}.csr" >/dev/null 2>&1
    openssl x509 \
        -req -days 3650 -in "${sslfile}.csr" \
        -signkey "${sslfile}.key" -out "${sslfile}.crt" >/dev/null 2>&1
    cat "${sslfile}.crt" "${sslfile}.key" > "${sslfile}.pem"
fi
