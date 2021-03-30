#!/bin/bash

# on Debian based systems, as root

RED='\033[0;31m'
NC='\033[0m'

# checks

if [[ -z "${REGION_OVERRIDE}" ]]; then
    printf "please set your ${RED}region${NC} before running this script with\n"
    printf "${RED}export REGION_OVERRIDE=US915${NC}\n"
    printf "valid options are\n"
    printf "US915 | EU868 | EU433 | CN470 | CN779 | AU915 | AS923 | KR920 | IN865\n"
    break
fi

if [[ -z "${VERSION}" ]]; then
  VERSION="2021.03.22.0"
fi

if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

if [ ! -f "/etc/debian_version" ]; then
   printf "install script for ${RED}Debian based OS${NC} only!"
fi

distro=$(lsb_release -i | cut -f 2-)
arch=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
version=$(awk '/DISTRIB_RELEASE=/' /etc/*-release | sed 's/DISTRIB_RELEASE=//' | sed 's/[.]0/./')

if [ $arch = "aarch64" ] ; then
    arch="arm64"
elif [ $arch = "64" ] ;then
    arch="amd64"
else
    printf "install script for ${RED}ARM/AMD 64bits architecture${NC} only!"
    exit
fi

if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed, skipping this step"
    # command
else
    echo "Install docker on ${distro} ${version}"
    apt-get remove docker docker-engine docker.io containerd runc
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    # TODO: variabiliser l'archi
    echo \
    "deb [arch=${arch} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

printf "Miner ${RED}installation${NC}"

mkdir /root/miner_data
mkdir /root/miner_logs


docker run -d --restart always \
--env REGION_OVERRIDE=$REGION_OVERRIDE \
--publish 1680:1680/udp \
--publish 44158:44158/tcp \
--name helium-miner \
--mount type=bind,source=/root/miner_data,target=/var/data \
--mount type=bind,source=/root/miner_logs,target=/var/log/miner \
quay.io/team-helium/miner:miner-${arch}_${VERSION}_GA


printf "Check ${RED}connexion${NC} and ${RED}blockchain processing${NC}"

# general info
docker exec helium-miner miner peer book -s

# those should match
docker exec helium-miner miner info height
curl https://api.helium.io/v1/blocks/height

printf "POST INSTALL steps: you should ${RED}backup${NC} ~/miner_data/miner/swarm_key"