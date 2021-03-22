provider "aws" {
  profile = "default"
  region  = var.region
}

####################
# module VPC
####################

module "vpc" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
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

locals {
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  database_subnets = module.vpc.database_subnets
}

##########################
# module Security Group
##########################

module "bastion_sg" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  # 
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${var.name}-bastion"
  description = "${var.name} Security group for bastion"
  vpc_id      = local.vpc_id

  egress_rules        = var.bastion_egress_rules
  ingress_cidr_blocks = var.bastion_ingress_cidr_blocks
  ingress_rules       = var.bastion_ingress_rules
}

module "alb_sg" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  # 
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${var.name}-alb"
  description = "${var.name} Security group for alb"
  vpc_id      = local.vpc_id

  egress_rules        = var.alb_egress_rules
  ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  ingress_rules       = var.alb_ingress_rules
}

module "was_sg" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  # 
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${var.name}-was"
  description = "${var.name} Security group for was"
  vpc_id      = local.vpc_id

  egress_rules = ["all-all"]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.alb_sg.this_security_group_id}"
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion_sg.this_security_group_id}"
    },
  ]
  # Number of computed ingress rules to create where 'source_security_group_id' is used
  number_of_computed_ingress_with_source_security_group_id = 2
}

module "db_sg" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  # 
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${var.name}-db"
  description = "${var.name} Security group for mysql ports"
  vpc_id      = local.vpc_id

  egress_rules        = var.db_egress_rules
  ingress_cidr_blocks = length(var.db_ingress_cidr_blocks) > 0 ? var.db_ingress_cidr_blocks : [local.vpc_cidr_block]
  ingress_rules       = var.db_ingress_rules
}

# custom sample
module "custom_sg" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  # 
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "${var.name}-custom"
  description = "${var.name} Security group for custom ports"
  vpc_id      = local.vpc_id

  egress_rules        = ["all-all"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  # custom port & postgresql
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "Custom ports"
      cidr_blocks = local.vpc_cidr_block
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = local.vpc_cidr_block
    },
  ]
}

locals {
  bastion_sg_id = module.bastion_sg.this_security_group_id
  alb_sg_id     = module.alb_sg.this_security_group_id
  was_sg_id     = module.was_sg.this_security_group_id
  db_sg_id      = module.db_sg.this_security_group_id
  custom_sg_id  = module.custom_sg.this_security_group_id
}

##########################
# module EC2
##########################

# EC2 AMI - Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
yum -y update
EOF

  was_user_data = <<EOF
#include https://go.aws/38GIqcB
EOF
}

resource "aws_eip" "bastion" {
  count    = 1
  vpc      = true
  instance = module.bastion.id[0]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-bastion"
    }
  )
}

module "bastion" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
  #
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  instance_count = 1

  name = "${var.name}-bastion"
  ami  = data.aws_ami.amazon_linux.id //"ami-09c5e030f74651050" //Amazon Linux 2 

  instance_type               = var.bastion_instance_type
  key_name                    = var.bastion_key_name
  disable_api_termination     = var.bastion_termination_protection
  associate_public_ip_address = var.bastion_associate_public_ip_address
  monitoring                  = var.bastion_monitoring
  cpu_credits                 = var.bastion_cpu_credits

  # subnet_id                   = local.public_subnets[0]
  subnet_ids             = local.public_subnets
  vpc_security_group_ids = [local.bastion_sg_id]
  user_data_base64       = base64encode(local.user_data)

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = var.bastion_volume_size
      delete_on_termination = true
    },
  ]

  tags = var.tags
}

module "was" {
  # 
  # public registry
  #   https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
  #
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  instance_count = 2

  name = "${var.name}-was"
  ami  = data.aws_ami.amazon_linux.id //"ami-09c5e030f74651050" //Amazon Linux 2 

  instance_type               = var.was_instance_type
  key_name                    = var.was_key_name
  disable_api_termination     = var.was_termination_protection
  associate_public_ip_address = var.was_associate_public_ip_address
  monitoring                  = var.was_monitoring
  cpu_credits                 = var.was_cpu_credits

  subnet_ids             = local.private_subnets
  vpc_security_group_ids = [local.was_sg_id]
  user_data_base64       = base64encode(local.was_user_data)

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = var.was_volume_size
      delete_on_termination = true
    },
  ]

  # ebs_block_device = [
  #   {
  #     device_name = "/dev/sdf"
  #     volume_type = "gp3"
  #     volume_size = 10
  #     encrypted   = true
  #     kms_key_id  = aws_kms_key.this.arn
  #   }
  # ]

  tags = var.tags
}
