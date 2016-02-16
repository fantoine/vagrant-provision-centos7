#!/bin/bash

if [ ! -f /etc/php.d/twig.ini ]; then
    echo 'Installing Twig PHP extension'

    mkdir -p /tmp/twig

    # Download twig
    git clone https://github.com/twigphp/Twig.git /tmp/twig >/dev/null 2>&1

    # Compile & Install
    pushd /tmp/twig/ext/twig/ >/dev/null 2>&1
    phpize >/dev/null 2>&1
    ./configure >/dev/null 2>&1
    make >/dev/null 2>&1
    make install >/dev/null 2>&1
    popd >/dev/null 2>&1

    # Clean temporary files
    rm -rf /tmp/twig

    # Enable module
    echo '; Enable twig extension module' > /etc/php.d/twig.ini
    echo 'extension=twig.so' >> /etc/php.d/twig.ini

    # Restart Apache
    service httpd restart >/dev/null 2>&1
fi
