resource "aws_vpc" "cloudheight_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    name = var.env_code
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)

  vpc_id = aws_vpc.cloudheight_vpc.id

  cidr_block = var.private_subnets_cidr[count.index]

  availability_zone = data.aws_availability_zones.available-names.names[count.index]

  tags = {
    name = "${var.env_code}-private${count.index}"
  }
}

data "aws_availability_zones" "available-names" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)

  vpc_id     = aws_vpc.cloudheight_vpc.id
  cidr_block = var.public_subnets_cidr[count.index]

  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available-names.names[count.index]

  tags = {
    name = "${var.env_code}-public${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.cloudheight_vpc.id

  tags = {
    name = var.env_code
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    name = "${var.env_code}-main${count.index}"
  }
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets_cidr)

  domain = "vpc"

  tags = {
    name = "${var.env_code}-nats${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cloudheight_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets_cidr)

  vpc_id = aws_vpc.cloudheight_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    name = "private${count.index}"
  }
}