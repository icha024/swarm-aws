provider "aws" {
  access_key = "${var.ACCESS_KEY}"
  secret_key = "${var.SECRET_KEY}"
  region     = "eu-west-2"
}

data "template_file" "install-cluster-manager" {
  template = "${file("${path.module}/templates/install-cluster-manager.sh")}"

  vars {
    gpg_password = "asdf"
  }
}

data "template_file" "join-cluster" {
  template = "${file("${path.module}/templates/join-cluster.sh")}"

  vars {
    swarm_master_ip = "${aws_instance.swarm-manager.private_ip}"
    gpg_password    = "asdf"
  }
}

resource "aws_instance" "swarm-manager" {
  ami                    = "ami-941e04f0"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = "${var.security_group_ids}"
  user_data              = "${data.template_file.install-cluster-manager.rendered}"

  root_block_device = {
    delete_on_termination = true
    volume_size           = 10
  }

  tags {
    Name = "swarm-manager-${count.index}"
  }
}

resource "aws_instance" "swarm-worker" {
  ami                    = "ami-941e04f0"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = "${var.security_group_ids}"
  user_data              = "${data.template_file.join-cluster.rendered}"
  count                  = 1

  root_block_device = {
    delete_on_termination = true
    volume_size           = 10
  }

  tags {
    Name = "swarm-worker-${count.index}"
  }
}

output "manager-public-ip" {
  value = "${aws_instance.swarm-manager.public_ip}"
}

output "manager-private-ip" {
  value = "${aws_instance.swarm-manager.private_ip}"
}

output "worker-public-ip" {
  value = ["${aws_instance.swarm-worker.*.public_ip}"]
}

# resource "aws_vpc" "swarm-vpc" {
#   cidr_block = "10.0.0.0/16"
# }


# resource "aws_subnet" "swarm-subnet" {
#   vpc_id            = "${aws_vpc.foo.id}"
#   availability_zone = "us-west-2a"
#   cidr_block        = "10.0.1.0/24"
# }

