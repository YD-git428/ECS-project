resource "aws_vpc" "ecs_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecs-project-vpc"
  }

  lifecycle {
    prevent_destroy = false  
  }

}
resource "aws_internet_gateway" "ecs-igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_route_table" "ecs_route_table_pub" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-igw.id
  }
  
  tags = {
    Name = "ecs-rtable-project"
  }
}


resource "aws_subnet" "ecs_public_subnet1" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
  

  tags = {
    Name = "ecs-project-sub"
  }
}
resource "aws_subnet" "ecs_public_subnet2" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2b"
  
  

  tags = {
    Name = "ecs-project-sub2"
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
  name        = "allow_HTTP"
  description = "Allow HTTPS and HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    description      = "Allow HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }

  ingress {
    description      = "Allow HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }

  ingress {
    description      = "Container port"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  
    cidr_blocks      = ["0.0.0.0/0"]  
  }


tags = {
    Name = "ecs-sg"
  }
}

