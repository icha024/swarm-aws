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
