output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnets_cidr_blocks" {
  value = module.vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}

####################
# module SG
####################

output "bastion_sg_id" {
  value = module.bastion_sg.this_security_group_id
}

output "alb_sg_id" {
  value = module.alb_sg.this_security_group_id
}

output "web_sg_id" {
  value = module.was_sg.this_security_group_id
}

output "db_sg_id" {
  value = module.db_sg.this_security_group_id
}

output "custom_sg_id" {
  value = module.custom_sg.this_security_group_id
}


####################
# module EC2
####################

output "bastion_id" {
  value = module.bastion.id
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "was_ids" {
  value = module.was.id
}

output "was_private_ips" {
  value = module.was.private_ip
}


####################
# module ALB
####################

output "alb_dns_name" {
  value = module.alb.this_lb_dns_name
}

output "alb_arn" {
  value = module.alb.this_lb_arn
}


####################
# module RDS
####################

output "db_instance_endpoint" {
  value = module.rds.this_db_instance_endpoint
}
