provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

/*
resource "aws_route_table" "myapp-rout-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}
*/

module "subnet-module" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}


module "myapp-server" {
    source = "./modules/webserver"
    my-ip = var.my-ip
    env_prefix = var.env_prefix
    instance_type = var.instance_type
    public_key_location = var.public_key_location
    private_key = var.private_key
    avail_zone = var.avail_zone
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_id = module.subnet-module.subnet.id

  
}
