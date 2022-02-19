
resource "aws_internet_gateway" "jp-igw" {
  vpc_id = aws_vpc.jp-vpc.id
  tags = {
    Name = "jp-igw"
  }
}

resource "aws_route_table" "jp-public-routes" {
  vpc_id = aws_vpc.jp-vpc.id
  tags = {
    Name = "jp-public-routes"
  }
}

resource "aws_route_table" "jp-private-1a-routes" {
  vpc_id = aws_vpc.jp-vpc.id
  tags = {
    Name = "jp-private-1a-routes"
  }
}

resource "aws_route_table" "jp-private-1c-routes" {
  vpc_id = aws_vpc.jp-vpc.id
  tags = {
    Name = "jp-private-1c-routes"
  }
}

resource "aws_route" "jp-public-route" {
  route_table_id = aws_route_table.jp-public-routes.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.jp-igw.id
}

resource "aws_route" "jp-private1a-route" {
  route_table_id = aws_route_table.jp-private-1a-routes.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat-1a-gw.id
}

resource "aws_route" "jp-private1c-route" {
  route_table_id = aws_route_table.jp-private-1c-routes.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat-1c-gw.id
}

resource "aws_route_table_association" "jp-public1a-routes-association" {
  subnet_id      = aws_subnet.public-1a-elb.id
  route_table_id = aws_route_table.jp-public-routes.id
}

resource "aws_route_table_association" "jp-public1c-routes-association" {
  subnet_id      = aws_subnet.public-1c-elb.id
  route_table_id = aws_route_table.jp-public-routes.id
}

resource "aws_route_table_association" "jp-private1a-instance-routes-association" {
  subnet_id      = aws_subnet.private-1a-instance.id
  route_table_id = aws_route_table.jp-private-1a-routes.id
}

resource "aws_route_table_association" "jp-private1a-database-routes-association" {
  subnet_id      = aws_subnet.private-1a-database.id
  route_table_id = aws_route_table.jp-private-1a-routes.id
}

resource "aws_route_table_association" "jp-private-1c-instance-routes-association" {
  subnet_id      = aws_subnet.private-1c-instance.id
  route_table_id = aws_route_table.jp-private-1c-routes.id
}

resource "aws_route_table_association" "jp-private-1c-database-routes-association" {
  subnet_id      = aws_subnet.private-1c-database.id
  route_table_id = aws_route_table.jp-private-1c-routes.id
}