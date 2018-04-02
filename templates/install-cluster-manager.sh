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

# Create Swarm
docker swarm init
touch /tmp/swarm-started

apt-get -y install nginx
docker swarm join-token worker --quiet | gpg --symmetric --armor --passphrase "${swarm_token_password}" > /tmp/token
mv /tmp/token /usr/share/nginx/html/token
touch /tmp/nginx-started

# Check docker events to trigger cluster balancing every 2 minutes
touch /usr/local/bin/balance-swarm.sh
chmod +x /usr/local/bin/balance-swarm.sh
cat > /usr/local/bin/balance-swarm.sh <<EOF
    #!/bin/sh
    events=\$$(docker events --since \$$(date +%Y-%m-%dT%H:%M:%S -d '2 min ago') --filter 'type=node' --filter 'event=create' --format '{{json .}}' --until \$$(date +%Y-%m-%dT%H:%M:%S))

    if [ \$$events ]
    then
        docker service ls --filter 'mode=replicated' --format "{{.Name}}" | xargs -I '{}' timeout 120 docker service update '{}' --force &
    fi
EOF

echo '*/2 * * * *   root    cd / && sh /usr/local/bin/balance-swarm.sh' >> /etc/crontab

# Automated weekly update
touch /etc/cron.weekly/unattended-upgrade.sh
chmod +x /etc/cron.weekly/unattended-upgrade.sh
cat > /etc/cron.weekly/unattended-upgrade.sh <<EOF
    #!/bin/sh
    apt-get update
    unattended-upgrade
EOF
