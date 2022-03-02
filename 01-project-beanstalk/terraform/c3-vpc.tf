resource "aws_vpc" "jp-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jp-vpc"
  }
}