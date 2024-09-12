terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.6.2"
    }
  }
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  subnet_cidr_block = var.subnet_cidr_block
  vpc_id = aws_vpc.myapp-vpc.id
}

module "myapp-webserver" {
  source = "./modules/webserver"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  my_ip = var.my_ip
  private_key_location = var.private_key_location
  public_key_location = var.public_key_location
  subnet_id = module.myapp-subnet.subnet.id
  vpc_id = aws_vpc.myapp-vpc.id
}