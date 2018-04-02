## Docker swarm ports requirements

See https://docs.docker.com/engine/swarm/swarm-tutorial/#install-docker-engine-on-linux-machines
```
Open protocols and ports between the hosts
The following ports must be available. On some systems, these ports are open by default.

TCP port 2377 for cluster management communications
TCP and UDP port 7946 for communication among nodes
UDP port 4789 for overlay network traffic
```

EFS port
```
2049 TCP
```

Templating: https://github.com/hashicorp/terraform/issues/15491

Trim command, screen-scrap:
```
docker swarm join-token worker | sed -n '3p' | sed 's/    //'
```
(or use `--quiet`)


Alternative to cloud-init (All cloud provider, but not AWS ASG)
```
provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install ..."
    ]
}
provisioner "file" {
    source = "local-source.file"
    destination = "/path/to/dest.file"
}
```

Services
```
docker service create --replicas 3 --name nist-mirror --constraint 'node.role!=manager' -p 8080:80  icha024/n-mirror:20180401
docker service ps nist-mirror
docker service update nist-mirror --force
docker service ps nist-mirror

docker network create monitoring --opt encrypted -d overlay
docker service create \
    --network=monitoring \
    --name portainer \
    --publish 9000:9000 \
    --mount "type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock" \
    --mount "type=volume,dst=/data" \
    --constraint "node.role==manager" \
    portainer/portainer --host=unix:///var/run/docker.sock
docker service create \
    --network=monitoring \
    --name go-collect-logs \
    --publish 10514:10514/TCP \
    --publish 10514:10514/UDP \
    --publish 3000:3000 \
    --constraint "node.role==manager" \
    icha024/go-collect-logs go-wrapper run -stdout=false
docker service create \
    --network=monitoring \
    --name logspout \
    --mode global \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    -e SYSLOG_FORMAT=rfc3164 \
    gliderlabs/logspout syslog://go-collect-logs:10514
```
