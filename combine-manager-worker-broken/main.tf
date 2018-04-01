provider "aws" {
  access_key = "${var.ACCESS_KEY}"
  secret_key = "${var.SECRET_KEY}"
  region     = "${var.region}"
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
  template = "${file("${path. odule}/templates/join-cluster.sh")}"

  vars {
    swarm_master_ip      = "${aws_instance.swarm-manager.private_ip}"
    swarm_token_password = "${random_string.swarm-token-password.result}"
  }
}

resource "aws_instance" "swarm-manager" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = "${var.existing_security_group_ids}"

  # subnet_id              = "${aws_subnet.swarm-subnet.id}"
  # vpc_security_group_ids = ["${aws_security_group.swarm-sg.id}"]
  user_data = "${data.template_file.install-cluster-manager.rendered}"

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
  vpc_security_group_ids = "${var.existing_security_group_ids}"

  # subnet_id              = "${aws_subnet.swarm-subnet.id}"
  # vpc_security_group_ids = ["${aws_security_group.swarm-sg.id}"]
  user_data = "${data.template_file.join-cluster.rendered}"

  count = 2

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

/* Optional. Disable to use existing default. */


# resource "aws_internet_gateway" "swarm-gw" {
#   vpc_id = "${aws_vpc.swarm-vpc.id}"


#   tags {
#     Name = "swarm-gw"
#   }
# }


# resource "aws_vpc" "swarm-vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
# }


# resource "aws_subnet" "swarm-subnet" {
#   vpc_id            = "${aws_vpc.swarm-vpc.id}"
#   availability_zone = "${var.availability_zone}"
#   cidr_block        = "10.0.1.0/24"


#   tags {
#     Name = "swarm-subnet"
#   }
# }


# resource "aws_security_group" "swarm-sg" {
#   name   = "swarm-sg"
#   vpc_id = "${aws_vpc.swarm-vpc.id}"


#   lifecycle {
#     create_before_destroy = true
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   /* SSH */
#   ingress {
#     from_port   = "22"
#     to_port     = "22"
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   /* Docker: TCP port 2377 for cluster management communications */
#   ingress {
#     from_port = "2377"
#     to_port   = "2377"
#     protocol  = "tcp"
#     self      = true
#   }


#   /* Docker: TCP and UDP port 7946 for communication among nodes */
#   ingress {
#     from_port = "7946"
#     to_port   = "7946"
#     protocol  = "tcp"
#     self      = true
#   }


#   /* Docker: TCP and UDP port 7946 for communication among nodes */
#   ingress {
#     from_port = "7946"
#     to_port   = "7946"
#     protocol  = "udp"
#     self      = true
#   }


#   /* Docker: UDP port 4789 for overlay network traffic */
#   ingress {
#     from_port = "4789"
#     to_port   = "4789"
#     protocol  = "udp"
#     self      = true
#   }


#   /* For broadcasting Swarm token */
#   ingress {
#     from_port = "80"
#     to_port   = "80"
#     protocol  = "tcp"
#     self      = true
#   }
# }

