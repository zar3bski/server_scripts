#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
ENDCOLOR="\e[0m"

log(){
    # Usage : log "message" [error|warn]
    if [[ -z "$2" ]]; then
        printf "${GREEN}${1}${ENDCOLOR}\n"
    elif [[ "$2" == error ]]; then
        printf "${RED}${1}${ENDCOLOR}\n"
    elif [[ "$2" == warn ]]; then
        printf "${YELLOW}${1}${ENDCOLOR}\n"
    fi
}

ansi()          { echo -e "\e[${1}m${*:2}\e[0m"; }
bold()          { ansi 1 "$@"; }
italic()        { ansi 3 "$@"; }
underline()     { ansi 4 "$@"; }

if [ "$EUID" -ne 0 ]; then
    log "Please run as root" error
    exit
fi

distro=$(lsb_release -i | cut -f 2- | tr '[:upper:]' '[:lower:]')
arch=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
version=$(awk '/DISTRIB_RELEASE=/' /etc/*-release | sed 's/DISTRIB_RELEASE=//' | sed 's/[.]0/./')
