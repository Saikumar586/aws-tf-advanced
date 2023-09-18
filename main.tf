resource "aws_vpc" "main" {
  
    cidr_block = var.cidr_blocks
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support

    tags = merge(var.vpc_tags, var.default_tags)

}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    default_tags,ig_tags)

}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
 count =  length(var.public_subnet )#"10.0.1.0/24"
  cidr_block = var.public_subnet[count.index]
 availability_zone = local.azs[count.index] # the reason using locals instead variables user cannot override the values.
    tags = merge(
    var.default_tags, {Name = "${var.public_subnet_tags}-public-${local.azs[count.index]}"}
    )
  }

  resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
 count =  length(var.private_subnet )#"10.0.1.0/24"
 map_public_ip_on_launch = true
  cidr_block = var.private_subnet[count.index]
 availability_zone = local.azs[count.index] # the reason using locals instead variables user cannot override the values.
    tags = merge(
    var.default_tags, {Name = "${var.priavte_subnet_tags}-priavte-${local.azs[count.index]}"}
    )
  }


  
#   resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.main.id
#  count =  length(var.private_subnet )#"10.0.1.0/24"
#   cidr_block = var.private_subnet[count.index]
#  availability_zone = local.azs[count.index] # the reason using locals instead variables user cannot override the values.
#     tags = merge(
#     var.default_tags, {Name = "${var.priavte_subnet_tags}-priavte-${local.azs[count.index]}"}
#     )
#   }


resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
 count =  length(var.database_subnet )#"10.0.1.0/24"
  cidr_block = var.database_subnet[count.index]
 availability_zone = local.azs[count.index] # the reason using locals instead variables user cannot override the values.
    tags = merge(
    var.default_tags, {Name = "${var.database_subnet_tags}-database-${local.azs[count.index]}"}
    )
  }


# resource "aws_route" "public" {
#   route_table_id            = aws_route_table.public.id
#   destination_cidr_block    = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.gw.id
#   depends_on  = [aws_route_table.public]
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.route_tags}-public"
    },var.public_route_table_tags   
  )
}

 #An Elastic IP address is allocated to your AWS account, and is yours until you release it. By using an Elastic  IP address, you can mask the failure of an instance or software by rapidly remapping the address to another instance in your account.

  resource "aws_eip" "eip" {  
      domain   = "vpc"
  }

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.nat_gateway_tags
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-private"
    },
    var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-database"
    },
    var.database_route_table_tags
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

resource "aws_db_subnet_group" "roboshop" {
  name       = var.project_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.db_subnet_group_tags
  )
}


