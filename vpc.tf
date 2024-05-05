module "label_vpc" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "label"
  name      = "vpc"
  delimiter = "_"

  tags = {
    Name = "vpc"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}
# =========================
# Create your subnets here
# =========================

module "subnet_addresses" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr
  networks = [
    {
      name     = "public"
      new_bits = local.subnet_cidr_new_bits
    },
    {
      name     = "private"
      new_bits = local.subnet_cidr_new_bits
    }
  ]
}


data "aws_availability_zones" "available" {
  state = "available"
}

module "label_public_subnet" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "label"
  name      = "public-subnet"
  delimiter = "_"

  tags = {
    Name = "public-subnet"
  }
}

module "label_private_subnet" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "label"
  name      = "private-subnet"
  delimiter = "_"

  tags = {
    Name = "private-subnet"
  }
}

locals {
  cidr_parts           = split("/", var.vpc_cidr)
  network_bits         = element(local.cidr_parts, 3)
  subnet_prefix        = 24
  subnet_cidr_new_bits = local.subnet_prefix - local.network_bits
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
     tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = module.label_vpc
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "main" {
    domain = "vpc"
    depends_on = [ aws_internet_gateway.main ]
  
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = module.subnet_addresses.network_cidr_blocks.public
  tags              = module.label_public_subnet.tags
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = module.subnet_addresses.network_cidr_blocks.private
  tags              = module.label_private_subnet.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
  tags = module.label_private_subnet.tags
}
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = module.label_private_subnet.tags
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private.id
}