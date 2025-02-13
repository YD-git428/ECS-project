resource "aws_vpc" "ecs_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_tag
  }

  lifecycle {
    prevent_destroy = false
  }

}
resource "aws_internet_gateway" "ecs-igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = var.igw_tag
  }
}

resource "aws_route_table" "ecs_route_table_pub" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-igw.id
  }

  tags = {
    Name = var.route_table_tag
  }
}


resource "aws_subnet" "ecs_public_subnet1" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.availability_zone1


  tags = {
    Name = var.subnet1_tag
  }
}
resource "aws_subnet" "ecs_public_subnet2" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone2



  tags = {
    Name = var.subnet2_tag
  }
}

resource "aws_route_table_association" "subnet-1" {
  subnet_id      = aws_subnet.ecs_public_subnet1.id
  route_table_id = aws_route_table.ecs_route_table_pub.id
}

resource "aws_route_table_association" "subnet-2" {
  subnet_id      = aws_subnet.ecs_public_subnet2.id
  route_table_id = aws_route_table.ecs_route_table_pub.id
}
resource "aws_security_group" "ecs_sg_project" {
  name        = "allow_HTTP&HTTPS"
  description = "Allow HTTPS and HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Container port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    description = "Allow outbound traffic to all ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = var.security_group_tag
  }
}

