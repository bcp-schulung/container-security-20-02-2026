sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker ps

sudo apt install uidmap
id -u
whoami
grep ^$(whoami): /etc/subuid
grep ^$(whoami): /etc/subgid
sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
sudo apt update

sudo apt-get install -y docker-ce-rootless-extras
dockerd-rootless-setuptool.sh install --force
docker info