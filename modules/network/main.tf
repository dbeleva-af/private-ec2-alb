resource "aws_vpc" "server-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "server-vpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  tags = {
    Name = "public-subnet-1"
  }
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.server-vpc.id
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "public-subnet-2" {
  tags = {
    Name = "public-subnet-2"
  }
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.server-vpc.id
  availability_zone = var.availability_zones[1]
}

resource "aws_subnet" "private-subnet-1" {
  tags = {
    Name = "private-subnet-1"
  }
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.server-vpc.id
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "private-subnet-2" {
  tags = {
    Name = "private-subnet-2"
  }
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.server-vpc.id
  availability_zone = var.availability_zones[1]
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "igw"
  }
  vpc_id = aws_vpc.server-vpc.id
}


resource "aws_eip" "for-nat" {
  domain                    = "vpc"
  depends_on                = [aws_internet_gateway.igw]
}


resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.for-nat.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "ngw"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.server-vpc.id

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.server-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "nat-ngw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}
resource "aws_route_table_association" "public-route-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}
resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}
resource "aws_route_table_association" "private-route-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-2.id
}

