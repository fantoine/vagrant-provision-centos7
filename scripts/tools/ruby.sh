#!/bin/bash

read -a gems <<< "$1"
tmpRuby=/tmp/rubysetup.sh

if [ ! -f /usr/local/rvm/bin/rvm ]; then
    echo 'Installing Ruby'

    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 >/dev/null 2>&1

    # Compacting gems
    if [ ${#gems[@]} -gt 0 ]; then
        gemsCmd=$(printf ',%s' "${gems[@]}")
        gemsCmd="--gems=${gemsCmd:1}"
    fi

    # Install RVM/Ruby/RubyGem
    wget -O $tmpRuby get.rvm.io >/dev/null 2>&1
    chmod +x $tmpRuby
    $tmpRuby stable --ruby $gemsCmd >/dev/null 2>&1
    rm $tmpRuby
    source /usr/local/rvm/scripts/rvm

    # Source RVM
    echo '# RVM/Ruby/RubyGem' >> /home/vagrant/.bashrc
    echo 'source /usr/local/rvm/scripts/rvm' >> /home/vagrant/.bashrc
fi
