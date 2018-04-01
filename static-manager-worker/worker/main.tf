provider "aws" {
  access_key = "${var.ACCESS_KEY}"
  secret_key = "${var.SECRET_KEY}"
  region     = "eu-west-2"
}

resource "aws_instance" "swarm-worker" {
  ami                    = "ami-941e04f0"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = "${var.security_group_ids}"
  user_data              = "${base64encode(file("${path.module}/join-cluster.sh"))}"
  count                  = 1

  root_block_device = {
    delete_on_termination = true
    volume_size           = 10
  }

  tags {
    Name = "swarm-worker-${count.index}"
  }
}

output "ip" {
  value = "Worker: ${aws_instance.swarm-worker.public_ip}"
}
