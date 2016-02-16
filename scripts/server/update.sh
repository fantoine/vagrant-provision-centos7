#!/bin/bash

# Update OS
echo 'Updating OS (takes a few time)'
yum update -y >/dev/null 2>&1

# Install some tools
echo 'Installing tools'
yum install -y \
    binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms \
    nano vim git curl htop wget zip unzip >/dev/null 2>&1
