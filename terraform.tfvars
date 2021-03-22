###############################################################################################################################################################################
# Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
# 
# Environment variables
# The terraform.tfvars file, if present.
# The terraform.tfvars.json file, if present.
# Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
# Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)
###############################################################################################################################################################################
#
# terraform cloud 와 별도로 동작
# terraform cloud 의 variables 와 동등 레벨
#
# Usage :
#
#   terraform apply -var-file=terraform.tfvars
#
#
# [Terraform Cloud] Environment Variables
#
#     AWS_ACCESS_KEY_ID
#     AWS_SECRET_ACCESS_KEY
#

####################
# Common
####################

region = "ap-northeast-2"
name   = "terraexam"

tags = {
  Terraform   = "true"
  Environment = "dev"
}


####################
# module VPC
####################

cidr = "10.0.0.0/16"

azs = ["ap-northeast-2a", "ap-northeast-2c"]

public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_tags = {
  Tier = "public"
}

private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
private_subnet_tags = {
  Tier = "private"
}

database_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
database_subnet_tags = {
  Tier = "db"
}

enable_nat_gateway     = true
single_nat_gateway     = true
one_nat_gateway_per_az = false

create_database_subnet_route_table     = true
create_database_nat_gateway_route      = false
create_database_internet_gateway_route = false
create_database_subnet_group           = true


##########################
# module Security Group
##########################

## Bastion SG
bastion_egress_rules        = ["all-all"]
bastion_ingress_cidr_blocks = ["211.60.50.190/32"]
bastion_ingress_rules       = ["ssh-tcp"]

## ALB SG
alb_egress_rules        = ["all-all"]
alb_ingress_cidr_blocks = ["0.0.0.0/0"]
alb_ingress_rules       = ["http-80-tcp", "https-443-tcp"]

## DB SG
db_egress_rules        = ["all-all"]
db_ingress_cidr_blocks = [] // []일경우, vpc_cidr_block
db_ingress_rules       = ["mysql-tcp"]


##########################
# module EC2
##########################

## Bastion
bastion_instance_type               = "t3.micro"
bastion_key_name                    = "ssh-key"
bastion_termination_protection      = false
bastion_associate_public_ip_address = true
bastion_monitoring                  = false
bastion_cpu_credits                 = "unlimited"
bastion_volume_size                 = 8

## WAS
was_instance_type               = "t3.micro"
was_key_name                    = "ssh-key"
was_termination_protection      = false
was_associate_public_ip_address = false
was_monitoring                  = true
was_cpu_credits                 = "unlimited"
was_volume_size                 = 10

