resource "aws_vpc" "main" {
    cidr_block = var.vpc_config.cidr_block
    tags = {
      name = var.vpc_config.name 
    } 
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    for_each = var.subnet_config  #key{cidr,az} each.jey and each.value
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az 

    tags = {
        name = each.key
    }
}

locals {
  public_subnet = {
    for key, config in var.subnet_config: key =>config if config.public
  }

    private_subnet = {
    for key, config in var.subnet_config: key =>config if !config.public
  }


}


#internet gateway, if user use one public subnet we will make an internetgateway 1 time

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    count = length(local.public_subnet) >0 ? 1 : 0 #we use ternary operatot means if there are multiple subnets and we want to create only single internet gateway for the public subnets then we use this 0 means nothing 1 means maximum(matlab max 1 gatway banao ) and if >1 then make only one gateway adn we all know these bcz in rootmain in subnet config in public we set true so it will make igw and if we use false then it wont maek any intenret gatweway(igw).   
}

#routing tables , it will also made when we have public subnets  
resource "aws_route_table" "main" {
    count = length(local.public_subnet) >0 ? 1 : 0 
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main[0].id
    }
}

#associating subnets

resource "aws_route_table_association" "main" {
    for_each = local.public_subnet

    subnet_id = aws_subnet.main[each.key].id
    route_table_id =aws_route_table.main[0].id

}


