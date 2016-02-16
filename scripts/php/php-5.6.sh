#!/bin/bash

timezone="$1"
modules="$2"
directory="$3"

$directory/php-common.sh php56w "$1" "$2"
