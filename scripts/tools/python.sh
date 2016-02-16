#!/bin/bash

version="$1"
read -a libraries <<< "$2"

if [ "$version" == "3" ] && [ ! -f /usr/local/bin/python3.4 ]; then
    echo 'Installing Python3'

    # Download python
    mkdir -p /tmp/python
    pushd /tmp/python >/dev/null 2>&1
    wget https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz >/dev/null 2>&1
    tar xf Python-3.* >/dev/null 2>&1
    pushd Python-3.* >/dev/null 2>&1

    # Compile
    ./configure >/dev/null 2>&1
    make >/dev/null 2>&1
    make altinstall >/dev/null 2>&1

    # Clean
    popd >/dev/null 2>&1
    popd >/dev/null 2>&1
    rm -rf /tmp/python

    # Create symlinks
    ln -s /usr/local/bin/python3.4 /usr/local/bin/python3 >/dev/null 2>&1
    ln -s /usr/local/bin/pip3.4 /usr/local/bin/pip3 >/dev/null 2>&1

    # Upgrade pip and install libraries
    /usr/local/bin/pip3.4 install --upgrade pip >/dev/null 2>&1
    if [ "${#libraries[@]}" -gt 0 ]; then
        /usr/local/bin/pip3.4 install ${libraries[@]} >/dev/null 2>&1
    fi
fi
