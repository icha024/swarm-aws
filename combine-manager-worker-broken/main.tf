provider "aws" {
  access_key = "${var.ACCESS_KEY}"
  secret_key = "${var.SECRET_KEY}"
  region     = "eu-west-2"
}

resource "random_string" "swarm-token-password" {
  # Generate and store the random string in TF state.
  length  = 32
  special = true
}

data "template_file" "install-cluster-manager" {
  template = "${file("${path.module}/templates/install-cluster-manager.sh")}"

  vars {
    swarm_token_password = "${random_string.swarm-token-password.result}"
  }
}

data "template_file" "join-cluster" {
  template = "${file("${path.module}/templates/join-cluster.sh")}"

  vars {
    swarm_master_ip      = "${aws_instance.swarm-manager.private_ip}"
    swarm_token_password = "${random_string.swarm-token-password.result}"
  }
}

resource "aws_instance" "swarm-manager" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
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
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = "${var.security_group_ids}"
  user_data              = "${data.template_file.join-cluster.rendered}"
  count                  = 2

  root_block_device = {
    delete_on_termination = true
    volume_size           = 10
  }

  depends_on = ["aws_instance.swarm-manager"]

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


# resource "aws_security_group" "swarm-sg" {
#   name   = "${module.label.id}"
#   vpc_id = "${var.vpc_id}"


#   lifecycle {
#     create_before_destroy = true
#   }


#   ingress {
#     from_port       = "2049"                     # NFS
#     to_port         = "2049"
#     protocol        = "tcp"
#     security_groups = ["${var.security_groups}"]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   tags = "${module.label.tags}"
# }

