#!/bin/sh
touch /tmp/user-data-script-run

apt-get update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
touch /tmp/updated-apt

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
touch /tmp/added-docker-repo

apt-get -y install docker-ce
usermod -a -G docker ubuntu
touch /tmp/installed-docker

docker swarm init
touch /tmp/swarm-started
