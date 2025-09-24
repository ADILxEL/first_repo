resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.eks_cluster_name}_main_vpc"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.eks_cluster_name}_igw"
  }
}
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index].id
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.eks_cluster_name}_public_subnet_${count.index}"
  }
}
resource "aws_subnet" "private"{
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[count.index].id
    availability_zone = var.availability_zones[count.index]

    tags = {
      Name = "${var.eks_cluster_name}_private_subnet_${count.index + 1}"
    }

}
resource "aws_eip" "nat" {
    count = length(var.public_subnet_cidr)
    domain = "vpc"

    tags = {
      Name = "${var.eks_cluster_name}_nat_eip_${count.index + 1}"
    }
}
resource "aws_nat_gateway" "nat" {
    count = length(var.public_subnet_cidr)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.eks_cluster_name}_nat_gateway_${count.index + 1}"
  }
  
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.eks_cluster_name}_public_route_table"
  } 
}
resource "aws_route_table_association" "public" {
    count=length(var.public_subnet_cidr)
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public[count.index].id
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main
    count = length(var.private_subnet_cidr)
   
   route = {
    cidr_block ="0.0.0.0/0"
    nat_gateway_id=aws_nat_gateway.nat[count.index].id
   }
   tags = {
     Name = "${var.eks_cluster_name}_private_route_table_${count.index + 1}"
   }

}
resource "aws_route_table_association" "name" {
    count=length(var.private_subnet_cidr)
    route_table_id =aws_route_table.private[count.index].id
    subnet_id =aws_subnet.private[count.index].id
}
