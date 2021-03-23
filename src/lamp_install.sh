#!/bin/bash

# add custom repo
echo Y | add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# usuals
apt-get update && echo Y | apt-get upgrade
echo Y | apt-get install nmap htop apache2 fail2ban

rm /var/www/html/index.html
a2dissite 000-default.conf

# set fail2ban up
rm /etc/fail2ban/jail.d/*.conf
touch /etc/fail2ban/jail.d/${HOSTNAME}_fail2ban.conf

printf '%s\n' \
   "[sshd]" \
   "enabled = true" \
   " " \
   "[apache]" \
   "enabled  = true" \
   "port     = http,https" \
   "filter   = apache-auth" \
   "logpath  = /var/log/apache*/*error.log" \
   "maxretry = 6" \
   " " \
   "[apache-overflows]" \
   " " \
   "enabled  = true" \
   "port     = http,https" \
   "filter   = apache-overflows" \
   "logpath  = /var/log/apache*/*error.log" \
   "maxretry = 2" \
   " " \
   "[apache-badbots]" \
   " " \
   "enabled  = true" \
   "port     = http,https" \
   "filter   = apache-badbots" \
   "logpath  = /var/log/apache*/*error.log" \
   "maxretry = 2" \
      >> /etc/fail2ban/jail.d/${HOSTNAME}_fail2ban.conf

# install certbot
echo Y | apt-get install python-certbot-apache -t stretch-backports

# Install docker
echo Y | apt-get remove docker docker-engine docker.io containerd runc
echo Y | apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-get update
echo Y | apt-get install docker-ce docker-ce-cli containerd.io

curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

## add CSP to Apache
conf_file=$(apache2ctl -V | grep SERVER_CONFIG_FILE | grep -Po "([a-z0-9]+\.conf)")

printf '%s\n' \
	 "" \
    "#########ADDED#MANUALLY##########" \
    "# mainly for security reasons" \
    "" \
    "<IfModule mod_headers.c>" \
    "Header set Content-Security-Policy \"default-src 'none';img-src 'self'; object-src 'none'; script-src 'self'; frame-src 'self' https://www.google.com https://www.youtube.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com\"" \
    "Header always set Strict-Transport-Security \"max-age=15552001; includeSubDomains;\"" \
    "Header set X-Frame-Options: SAMEORIGIN" \
    "</IfModule>" \
    >> /etc/apache2/${conf_file}

a2enmod headers

## enforce security on Apache
printf '%s\n' \
   "" \
   "ServerTokens Prod" \
   "ServerSignature Off" \
   "FileETag None" \
   "TraceEnable off" \
   >> /etc/apache2/${conf_file}

systemctl restart apache2
