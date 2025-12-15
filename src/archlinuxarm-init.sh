#!/bin/bash
#
# Initialisation script for Archlinux ARM. This script:
# - provision a new sudoer user 
# - disable default users and credentials
# - set hostname
# - set ssh key for admin user
# 
# Usage: 
#    archlinuxarm-init.sh <SUDOER USERNAME> <SUDOER PASSWORD> <NEW ROOT PASSWORD> "<SSH_KEY>" <HOSTNAME>

USERNAME=$1
PASSWORD=$2
NEW_ROOT_PASSWORD=$3
SSH_KEY=$4
HOSTNAME=$5

if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$NEW_ROOT_PASSWORD" || -z "$SSH_KEY" || -z "$HOSTNAME" ]]; then
  printf "usage:\n archlinuxarm-init.sh <SUDOER USERNAME> <SUDOER PASSWORD> <NEW ROOT PASSWORD> "<SSH_KEY>" <HOSTNAME>\n"
  exit 1
fi

if [ $UID != 0 ]; then
  echo "Script should run as root"
  exit 1
fi

echo "Install common packages"
pacman -Sy --noconfirm bash-completion

echo "Configure sudo"
pacman -Sy --noconfirm sudo 
groupadd -g 1555 sudoers
touch /etc/sudoers.d/local
echo "%sudoers      ALL=(ALL:ALL) ALL" > /etc/sudoers.d/local
chmod 440 /etc/sudoers.d/local
visudo -c /etc/sudoers.d/local

echo "Creating new sudoer user: $USERNAME"
useradd -m -U -G 1555 $USERNAME
printf "$PASSWORD\n$PASSWORD" | passwd $USERNAME
mkdir -p /home/$USERNAME/.ssh
touch /home/$USERNAME/.ssh/authorized_keys
echo $SSH_KEY > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

echo "Deleting provisioned 'alarm' user"
userdel -f alarm

echo "Changing root default password" 
printf "$NEW_ROOT_PASSWORD\n$NEW_ROOT_PASSWORD" | passwd root

echo "Setting environment for Ansible" 
pacman -Syq --noconfirm python python-pip

echo "SSHD tuning"
sed -i 's/.*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Set hostname"
sed -i "s/.*/${HOSTNAME}/" /etc/hostname

echo "clean bash history"
cat /dev/null > ~/.bash_history && history -c && exit 0
