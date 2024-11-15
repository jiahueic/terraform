# 1. Create a VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}
# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}
# 3. Create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}
# 4. Create a subnet
variable "subnet_prefix" {
  description = "cidr block for the subnet"

}
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_prefix
  availability_zone = "us-east-1a"
  tags = {
    Name = "prod-subnet"
  }
}
# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}
# 6. Create security group to allow port 22, 80, 443
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web"
  description = "Allow inbound traffic from port 22, 80 and 443"
  vpc_id      = aws_vpc.prod-vpc.id

  tags = {
    Name = "allow_web_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
variable "network_interface_ip" {
  description = "private ip for network interface"
}
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = [var.network_interface_ip]
  security_groups = [aws_security_group.allow_web_traffic.id]
}
# 8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "lb" {
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = var.network_interface_ip
  vpc                       = true
  depends_on                = [aws_internet_gateway.gw, aws_instance.web-server-instance]
}
output "server_public_ip" {
  value = aws_eip.lb.public_ip
}
# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami               = "ami-005fc0f236362e99f"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"
  network_interface {
    device_index         = 0 # meaning first network interface associated with the device
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl enable apache2
                sudo systemctl start apache2
                sudo bash -c 'echo "your very first web server" > /var/www/html/index.html'
                EOF
  tags = {
    Name = "web-server"
  }
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip


}

output "server_id" {
  value = aws_instance.web-server-instance.id
}


