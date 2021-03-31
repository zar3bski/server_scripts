
echo "Install docker on ${distro} ${version}"
apt-get remove docker docker-engine docker.io containerd runc
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL "https://download.docker.com/linux/${distro}/gpg" | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# TODO: variabiliser l'archi
echo \
"deb [arch=${arch} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${distro} \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io