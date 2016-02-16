#!/bin/bash

composer="$1"

if ! yum list installed hhvm >/dev/null 2>&1; then
    echo 'Installing hhvm'

    # Install HHVM
    rpm -i http://dheche.fedorapeople.org/hhvm/el6/RPMS/x86_64/hhvm-release-6-1.noarch.rpm
    yum install -y hhvm --enablerepo=epel,remi
fi

if [ "$composer" == true ]; then
    if ! grep -q "alias composer" /home/vagrant/.bashrc ; then
        echo 'Setup composer alias'
        echo '# Composer alias' >> /home/vagrant/.bashrc
        echo "alias composer='hhvm /usr/local/bin/composer'" >> /home/vagrant/.bashrc
    fi
fi
