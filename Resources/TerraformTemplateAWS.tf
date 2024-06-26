provider "aws" {
  region     = "THEREQUIREDREGION"
  access_key = "THEREQUIREDACCESSKEY"
  secret_key = "THEREQUIREDSECRETKEY"
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "deployer" {
  key_name   = "THEREQUIREDPEMKEY"
  public_key = tls_private_key.my_key.public_key_openssh
}

locals {
  pemkey = nonsensitive(tls_private_key.my_key.private_key_pem)
}

resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo '${local.pemkey}' > THEREQUIREDLOCPEMKEY/THEREQUIREDPEMKEY.pem"
  }
}

variable "num_instances" {
  description = "Number of instances"
  type        = number
  default     = THEREQUIREDINSTNUM
}

resource "aws_vpc" "THE1VAL1HASH_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "THE1VAL1HASH_vpc"
  }   
}

variable "availability_zone" {
  description = "Desired Availability Zone for the subnet"
  type        = string
  THESUBREGIONSUBSTITUTE
}

resource "aws_subnet" "THE1VAL1HASH_subnet" {
  vpc_id     = aws_vpc.THE1VAL1HASH_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone 
  tags = {
    Name = "THE1VAL1HASH_subnet"
  }   
}

resource "aws_internet_gateway" "THE1VAL1HASH_igy" {
  vpc_id = aws_vpc.THE1VAL1HASH_vpc.id
  tags = {
    Name = "THE1VAL1HASH_igy"
  }  
}

resource "aws_route_table" "THE1VAL1HASH_rt" {
  vpc_id = aws_vpc.THE1VAL1HASH_vpc.id
  tags = {
    Name = "THE1VAL1HASH_rt"
  }    
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.THE1VAL1HASH_igy.id
  }
}

resource "aws_route_table_association" "THE1VAL1HASH_rta" {
  subnet_id      = aws_subnet.THE1VAL1HASH_subnet.id
  route_table_id = aws_route_table.THE1VAL1HASH_rt.id
}

resource "aws_security_group" "THE1VAL1HASH_sg" {
  vpc_id      = aws_vpc.THE1VAL1HASH_vpc.id
  name        = "THE1VAL1HASH_sg"
  description = "Security group for SSH, HTTP, HTTPS, ICMP, and custom range"
THEAWSFIREWALLSETTINGS
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "THEREQUIREDINSTANCE" {
  count                       = var.num_instances
  ami                         = "THEREQUIREDAMI"
  instance_type               = "THEREQUIREDTYPE"
  subnet_id                   = aws_subnet.THE1VAL1HASH_subnet.id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.THE1VAL1HASH_sg.id]
  associate_public_ip_address = true
  availability_zone           = var.availability_zone  

  tags = {
    Name     = "THEREQUIREDINSTANCE-${count.index + 1}"
    Hostname = "THEREQUIREDINSTANCE-${count.index + 1}"
  }
}

output "public_ips" {
  value = aws_instance.THEREQUIREDINSTANCE.*.public_ip
}

output "instance_names" {
  value = aws_instance.THEREQUIREDINSTANCE.*.tags.Name
}

