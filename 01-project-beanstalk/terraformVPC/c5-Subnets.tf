resource "aws_vpc" "jp-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jp-vpc"
  }
}

resource "aws_subnet" "public-1a-elb" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = var.aws_region_1a
  tags = {
    Name = "public-1a-elb"
  }
}

resource "aws_subnet" "public-1c-elb" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = var.aws_region_1c
  tags = {
    Name = "public-1c-elb"
  }
}

resource "aws_subnet" "private-1a-instance" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.30.0/24"
  availability_zone = var.aws_region_1a
  tags = {
    Name = "private-1a-instance"
  }
}

resource "aws_subnet" "private-1c-instance" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.40.0/24"
  availability_zone = var.aws_region_1c
  tags = {
    Name = "private-1c-instance"
  }
}

resource "aws_subnet" "private-1a-database" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.50.0/24"
  availability_zone = var.aws_region_1a
  tags = {
    Name = "private-1a-database"
  }
}

resource "aws_subnet" "private-1c-database" {
  vpc_id = aws_vpc.jp-vpc.id
  cidr_block = "10.0.60.0/24"
  availability_zone = var.aws_region_1c
  tags = {
    Name = "private-1c-database"
  }
}