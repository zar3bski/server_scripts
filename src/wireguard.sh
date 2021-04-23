#!/bin/bash

source ./src/generic.sh
echo "Install wireguard on ${distro} ${version}"

apt-get install -y wireguard wireguard-tools net-tools linux-headers-`uname -r`

# set 
if [ -z ${WIREGUARD_PORT+x} ]; then
    WIREGUARD_PORT=51820
    echo "WIREGUARD_PORT is unset. Using ${WIREGUARD_PORT}"
fi

if [ -z ${WG0_IP+x} ]; then
    WG0_IP=10.10.10.1/24
    echo "WG0_IP is unset. Using ${WG0_IP}"
fi

# keys generation
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey

PRIVATE_KEY=$(cat privatekey)
PUBLIC_KEY=$(cat publickey)

cat <<EOT >> wg0.conf
[Interface]
## My VPN server private IP address ##
Address = $WG0_IP

## My VPN server port ##
ListenPort = $WIREGUARD_PORT

## VPN server's private key i.e. /etc/wireguard/privatekey ##
PrivateKey = $PRIVATE_KEY

# IPs that the client can use inside the VPN and his public key. uncomment
#[Peer]
#PublicKey =
#AllowedIPs = 

## Save and update this config file when a new peer (vpn client) added ##
SaveConfig = true

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOT

systemctl start wg-quick@wg0

printf "Wireguard successfully set up to listen to port ${WIREGUARD_PORT} on wg0 (${WG0_IP})\n
 you can now ${RED} set your first client up${NC} using $(hostname) ${RED}publickey${NC}\n
        ${PUBLIC_KEY}\n
Dont forget to edit /etc/wireguard/wg0.cong ${RED}[peer]${NC} section to register you client\n"
