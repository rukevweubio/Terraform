variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "Availability Zone for subnet 1"
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Availability Zone for subnet 2"
  default     = "us-east-1b"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0c94855ba95c71c99" # Ubuntu 18.04 LTS (adjust as needed)
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "my-key"
}
