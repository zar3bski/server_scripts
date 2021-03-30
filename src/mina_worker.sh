#!/bin/bash

source ./generic.sh

if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed, skipping this step"
else
    source ./install_docker.sh
fi

if [ -z ${KEY_GENERATOR_VERSION+x} ]; then
    KEY_GENERATOR_VERSION=1.0.2-06f3c5c
    echo "KEY_GENERATOR_VERSION is unset. Using ${KEY_GENERATOR_VERSION}"
fi

if [ $arch = "64" ] ;then
    arch="amd64"
else
    printf "install script for ${RED}AMD 64bits architecture${NC} only!\n"
    exit
fi


printf "${RED}Keypair ${NC}generation"

if [ -f "/root/keys/mina/my-wallet" ]; then
    printf "Keypair ${RED}already exists${NC} at /root/keys/mina\nChecking conformity\n"
    docker run --interactive --tty --rm --entrypoint=mina-validate-keypair --volume /root/keys/mina:/keys minaprotocol/generate-keypair:$KEY_GENERATOR_VERSION -privkey-path /keys/my-wallet
else
    printf "generating keys at ${RED}/root/keys/mina${NC}\n"
    docker run  --interactive --tty --rm --volume /root/keys/mina:/keys minaprotocol/generate-keypair:$KEY_GENERATOR_VERSION -privkey-path /keys/my-wallet
    chmod 600 /root/keys/mina/my-wallet
fi


# TODO: install worker

