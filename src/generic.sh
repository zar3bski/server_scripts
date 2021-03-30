#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'


if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

distro=$(lsb_release -i | cut -f 2-)
arch=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
version=$(awk '/DISTRIB_RELEASE=/' /etc/*-release | sed 's/DISTRIB_RELEASE=//' | sed 's/[.]0/./')

