provider "aws" {
  profile = "default"
  region  = var.region
}

module "vpc" {
  # 
  # public registry
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  # 
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"


  name = var.name
  cidr = var.cidr

  azs = var.azs

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnets     = var.public_subnets
  public_subnet_tags = var.public_subnet_tags

  private_subnets     = var.private_subnets
  private_subnet_tags = var.private_subnet_tags

  database_subnets     = var.database_subnets
  database_subnet_tags = var.database_subnet_tags

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  create_database_subnet_route_table     = var.create_database_subnet_route_table
  create_database_nat_gateway_route      = var.create_database_nat_gateway_route
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  create_database_subnet_group           = var.create_database_subnet_group

  tags = var.tags
}