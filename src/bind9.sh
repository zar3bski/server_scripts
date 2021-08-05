#!/bin/bash

source ./src/generic.sh
echo "Install bind on ${distro} ${version}"

apt-get install -y bind9 dnsutils