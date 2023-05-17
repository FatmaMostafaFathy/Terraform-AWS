resource "aws_vpc" "vpc" {
    cidr_block = var.cidr
    tags = {
        Name = "main"
    }
}

# public_subnet

resource "aws_subnet" "pub-subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pubsubnet
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "pub-subnet"
    }
}

# Private_subnet

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pvsubnet
    map_public_ip_on_launch = "false"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Private_subnet"
    }
}

# internetgateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "igw"
    }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = (aws_subnet.pub-subnet.id)

  tags = {
    Name  = "nat"    
  }
}

#Routetable

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "pv-route"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "pb_route"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id  = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id  = aws_internet_gateway.igw.id
}


resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private.id
}


# security-gp

resource "aws_security_group" "http-allowed" {
  vpc_id      = aws_vpc.vpc.id

  egress {
	  from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = ["0.0.0.0/0"]
    }
 ingress {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  }

#instance

resource "aws_instance" "public" {
    ami = "ami-06878d265978313ca"
    instance_type = "t2.micro"
    
    subnet_id = aws_subnet.pub-subnet.id
    vpc_security_group_ids = [aws_security_group.http-allowed.id]
    
    #key_name = "TFlab1"
    user_data = <<-EOF
    #!/bin/bash
    echo "*** Installing apache2"
    sudo apt update -y
    sudo apt install apache2 -y
    echo "*** Completed Installing apache2"
    EOF

    #connection {
     #   user = "${var.EC2_USER}"
      #  private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    #}
}
resource "aws_instance" "instance2" {
    ami = "ami-06878d265978313ca"
    instance_type = "t2.micro"
    
    subnet_id = aws_subnet.private-subnet.id
    
    vpc_security_group_ids = [aws_security_group.http-allowed.id]
    
    #key_name = "TFlab1"
    user_data = <<-EOF
    #!/bin/bash
    echo "*** Installing apache2"
    sudo apt update -y
    sudo apt install apache2 -y
    echo "*** Completed Installing apache2"
    EOF

    #connection {
     #   user = "${var.EC2_USER}"
      #  private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    #}
}


