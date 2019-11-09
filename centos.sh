#!/bin/bash

#  centos 7.6
#  accessible services dhcpv6-client docker-registry http https ssh

# install common tool
yum install -y nano

# install docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# install gitlab runner
curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
chmod +x /usr/local/bin/gitlab-runner
useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
usermod -aG docker gitlab-runner
gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
gitlab-runner start

# firewalld
yum install -y firewalld
systemctl start firewalld
systemctl enable firewalld

firewall-cmd --zone=public --add-service=http --add-service=ssh --add-service=https --add-service=docker-registry --permanent
firewall-cmd --add-interface=$(route | grep '^default' | grep -o '[^ ]*$') --permanent

if [[ $(firewall-cmd --state) == running ]] 
 	then echo "firewalld up and running" 
    else echo "CAREFUL: firewalld did not start!!!!!!!"
fi

# install fail2ban and create jail for ssh
yum install -y fail2ban
touch /etc/fail2ban/jail.d/local.conf

printf '%s\n' \
    "[DEFAULT]" \
	"bantime = 3600" \
	"action = %(action_)s" \
	" " \
	"[sshd]" \
	"enabled = true" \
    " " \
>> /etc/fail2ban/jail.d/local.conf

systemctl start fail2ban
systemctl enable fail2ban

