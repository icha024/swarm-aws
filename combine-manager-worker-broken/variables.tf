variable "ACCESS_KEY" {
  description = "access key"
}

variable "SECRET_KEY" {
  description = "secret key"
}

variable "security_group_ids" {
  default = ["sg-07939d6f"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 14.04"
  default     = "ami-941e04f0"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default     = "Ubt"
}
