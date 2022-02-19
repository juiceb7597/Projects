resource "aws_nat_gateway" "nat-1a-gw" {
  allocation_id = aws_eip.eip1.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public-1a-elb.id
  depends_on = [aws_internet_gateway.jp-igw]
  tags = {
    Name = "nat-1a-gw"
  }
}

resource "aws_nat_gateway" "nat-1c-gw" {
  allocation_id = aws_eip.eip2.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public-1c-elb.id
  depends_on = [aws_internet_gateway.jp-igw]
  tags = {
    Name = "nat-1c-gw"
  }
}