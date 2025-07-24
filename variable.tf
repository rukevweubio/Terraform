variable "region" {
  default = "us-east-1"
}

variable "vpc_a_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_b_cidr" {
  default = "10.1.0.0/16"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
 
  default = "ami-0fc5d935ebf8bc3bc"
}
