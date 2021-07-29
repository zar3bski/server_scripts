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

main_nic=$(ip -o -4 route show to default | awk '{print $5}')

# keys generation
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey

PRIVATE_KEY=$(cat privatekey)
PUBLIC_KEY=$(cat publickey)

# Wireguard setting
cat <<EOT >> wg0.conf
[Interface]
## My VPN server private IP address ##
Address = $WG0_IP

## My VPN server port ##
ListenPort = $WIREGUARD_PORT

## VPN server's private key i.e. /etc/wireguard/privatekey ##
PrivateKey = $PRIVATE_KEY


## Save and update this config file when a new peer (vpn client) added ##
SaveConfig = true

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $main_nic -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $main_nic -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $main_nic -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $main_nic -j MASQUERADE
EOT

chmod 600 /etc/wireguard/{privatekey,wg0.conf}

# Systemd integration

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Networking and Firewall Configuration

sed -i 's/.*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

ufw allow $WIREGUARD_PORT/udp || echo "Failed to allow port ${WIREGUARD_PORT} using ${RED}UFW${NC}"

printf "Wireguard successfully set up to listen to port ${WIREGUARD_PORT} on wg0 (${WG0_IP})\n
 you can now ${RED} set your first client up${NC} using $(hostname) ${RED}publickey${NC}\n
        ${PUBLIC_KEY}\n
Once done, register your client with\n
    wg set wg0 peer ${RED}<CLIENT_PUBLIC_KEY>${NC} allowed-ips ${RED}<ALLOWED IP>${NC}\n
NB: ${RED}ALLOWED IP${NC} are not IPs the client can reach but the IPs he can 'endorse'"
