terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
# !!Use your own access and secret keys!!
provider "aws"{
  skip_credentials_validation = true 
  skip_metadata_api_check = true
  skip_requesting_account_id = true
  region     = var.region
  access_key = "AKIA52LJEQNMWCTT53NX"
  secret_key = "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"
  endpoints{
    ec2 = "http://localhost:4566"
    }
} 
resource "aws_instance" "web-server-instance" {
  ami           = "ami-0c7217cdde317cfec"# Amazon Linux 2 AMI ID (you can choose a different one)
  instance_type = "t2.micro"             # Change this to your desired instance type

  
  
  }
  

# Creating a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block 
  tags = {
    "Name" = "Production ${var.main_vpc_name}"  # string interpolation
  }
}

# Creating a subnet in the VPC
resource "aws_subnet" "web"{
  vpc_id = aws_vpc.main.id
  cidr_block = var.web_subnet  
  availability_zone = var.subnet_zone
  tags = {
    "Name" = "Web subnet"
  }
}

# Creating an Intenet Gateway
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

#  Associating the IGW to the default RT
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"  # default route
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    "Name" = "my-default-rt"
  }
}

# Default Security Group
resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "Default Security Groupz"

  }
  ingress {
   description = "ssh ingress"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress{
  description = "smtp ingress"
  from_port   = 25
  to_port     = 25
  protocol    = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
 }
 ingress{
  from_port   = 80
  to_port     = 80
  protocol    ="tcp"
  description = "for allowing http"
  cidr_blocks  = ["0.0.0.0/0"]
 }
}
