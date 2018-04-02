#!/bin/sh
touch /tmp/user-data-script-run

# Install Basic Packages
apt-get update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
touch /tmp/updated-apt

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $$(lsb_release -cs) \
   stable"
apt-get update
touch /tmp/added-docker-repo

apt-get -y install docker-ce
usermod -a -G docker ubuntu
touch /tmp/installed-docker

# Delay before joining cluster - Master need to init first
sleep 10

# Join Cluster
curl ${swarm_master_ip}/token > /tmp/token
docker swarm join --token $$(cat /tmp/token | gpg --decrypt --passphrase "${swarm_token_password}") ${swarm_master_ip}:2377 | tee /tmp/swarm-joined

# Automated weekly update
touch /etc/cron.weekly/unattended-upgrade.sh
chmod +x /etc/cron.weekly/unattended-upgrade.sh
cat > /etc/cron.weekly/unattended-upgrade.sh <<EOF
    #!/bin/sh
    apt-get update
    unattended-upgrade
EOF
