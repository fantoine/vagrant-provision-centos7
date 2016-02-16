#!/bin/bash

composer="$1"

if ! yum list installed hhvm >/dev/null 2>&1; then
    echo 'Installing hhvm'

    # Install HHVM
    cat > /etc/yum.repos.d/debianized.repo <<- CONTENT
[debianized]
name=debianized packages for Enterprise Linux 7 - \$basearch
baseurl=http://repo.debianized.net/centos/7/RPMS/\$basearch
enabled=1
gpgcheck=0
CONTENT
    yum install -y hhvm-3.5.0
fi

if [ "$composer" == true ]; then
    if ! grep -q "alias composer" /home/vagrant/.bashrc ; then
        echo 'Setup composer alias'
        echo '# Composer alias' >> /home/vagrant/.bashrc
        echo "alias composer='hhvm /usr/local/bin/composer'" >> /home/vagrant/.bashrc
    fi
fi
