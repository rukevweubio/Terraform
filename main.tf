

resource "aws_vpc" "vpc_a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc_a"
  }
}

# VPC B
resource "aws_vpc" "vpc_b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc_b"
  }
}

# Subnets
resource "aws_subnet" "my_subnet_a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_a"
  }
}

resource "aws_subnet" "my_subnet_b" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_b"
  }
}

# Internet Gateways
resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
}

resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.vpc_b.id
}

# Route Tables
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }

  tags = {
    Name = "public-route-table-a"
  }
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.vpc_b.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }

  tags = {
    Name = "public-route-table-b"
  }
}

# Route Table Associations
resource "aws_route_table_association" "assoc_a" {
  subnet_id      = aws_subnet.my_subnet_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "assoc_b" {
  subnet_id      = aws_subnet.my_subnet_b.id
  route_table_id = aws_route_table.public_b.id
}

# VPC Peering
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc_a.id
  peer_vpc_id   = aws_vpc.vpc_b.id
  auto_accept   = true

  tags = {
    Name = "peer-a-b"
  }
}

# Add Peering Routes
resource "aws_route" "route_a_to_b" {
  route_table_id             = aws_route_table.public_a.id
  destination_cidr_block     = var.vpc_b_cidr
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_b_to_a" {
  route_table_id             = aws_route_table.public_b.id
  destination_cidr_block     = var.vpc_a_cidr
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
}


resource "aws_security_group" "allow_all_a" {
  name        = "allow-all-a"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_b_cidr, var.vpc_a_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_b" {
  name        = "allow-all-b"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_a_cidr, var.vpc_b_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "nginx" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.my_subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_all_a.id]
  associate_public_ip_address = true

  user_data = file("user_data_nginx.sh")

  tags = {
    Name = "nginx-server"
  }
}

resource "aws_instance" "mysql" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.my_subnet_b.id
  vpc_security_group_ids = [aws_security_group.allow_all_b.id]
  associate_public_ip_address = true

  user_data = file("user_data_mysql.sh")

  tags = {
    Name = "mysql-server"
  }
}
