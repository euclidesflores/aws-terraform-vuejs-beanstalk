data "aws_availability_zones" "available_zones" {}

resource "aws_vpc" "main" {
  cidr_block         = var.cidr
  enable_dns_support = true
  tags               = var.tags
}

resource "aws_security_group" "main" {
  name   = "app-security-group"
  vpc_id = aws_vpc.main.id

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]

      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      self             = false
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      ipv6_cidr_blocks = []
    }
  ]

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      self             = false
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      ipv6_cidr_blocks = []
    }
  ]

  tags = var.tags
}

resource "aws_subnet" "public" {
  count                   = var.subnets
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available_zones.names, count.index)
  cidr_block              = element(var.cidr_blocks, count.index)
  map_public_ip_on_launch = true
  tags                    = merge({ "AZ" = element(data.aws_availability_zones.available_zones.names, count.index) }, var.tags)
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "main" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  route_table_id         = aws_route_table.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.subnets
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.main.id
}
