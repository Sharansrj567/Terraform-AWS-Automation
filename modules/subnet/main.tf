resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = var.vpc_id
  availability_zone = var.avail_zone
  cidr_block = var.subnet_cidr_block
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  #  vpc_id = aws_vpc.myapp-vpc.id
  route_table_id = aws_route_table.myapp-route-table.id
}