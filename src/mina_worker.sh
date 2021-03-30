#!/bin/bash

source ./generic.sh

if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed, skipping this step"
else
    source ./install_docker.sh
fi

