variable "ACCESS_KEY" {
  description = "access key"
}

variable "SECRET_KEY" {
  description = "secret key"
}

variable "SSH_KEY_NAME" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "existing_security_group_ids" {
  default = ["sg-07939d6f"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "region" {
  default = "eu-west-2"
}

variable "availability_zone" {
  default = "eu-west-2a"
}
