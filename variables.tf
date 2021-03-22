####################
# Common
####################

variable "region" {}

variable "name" {}
variable "tags" {}


####################
# module VPC
####################

variable "cidr" {}
variable "azs" {}

variable "private_subnets" {}
variable "private_subnet_tags" {}

variable "public_subnets" {}
variable "public_subnet_tags" {}

variable "database_subnets" {}
variable "database_subnet_tags" {}

variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "one_nat_gateway_per_az" {}

variable "create_database_subnet_route_table" {}
variable "create_database_nat_gateway_route" {}
variable "create_database_internet_gateway_route" {}
variable "create_database_subnet_group" {}

####################
# module SG
####################

# Bastion SG
variable "bastion_egress_rules" {}
variable "bastion_ingress_cidr_blocks" {}
variable "bastion_ingress_rules" {}

# ALB SG
variable "alb_egress_rules" {}
variable "alb_ingress_cidr_blocks" {}
variable "alb_ingress_rules" {}

# DB SG
variable "db_egress_rules" {}
variable "db_ingress_cidr_blocks" {}
variable "db_ingress_rules" {}


##########################
# module EC2
##########################

## Bastion
variable "bastion_instance_type" {}
variable "bastion_key_name" {}
variable "bastion_termination_protection" {}
variable "bastion_associate_public_ip_address" {}
variable "bastion_monitoring" {}
variable "bastion_cpu_credits" {}
variable "bastion_volume_size" {}

## WAS
variable "was_instance_type" {}
variable "was_key_name" {}
variable "was_termination_protection" {}
variable "was_associate_public_ip_address" {}
variable "was_monitoring" {}
variable "was_cpu_credits" {}
variable "was_volume_size" {}



####################
# module ALB
####################

variable "load_balancer_type" {}
variable "http_tcp_listeners" {}
variable "https_listeners" {}
variable "target_groups" {}

