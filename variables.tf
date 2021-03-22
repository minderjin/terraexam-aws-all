variable "name" {}

variable "region" {}
variable "azs" {}
variable "cidr" {}

variable "private_subnets" {}
variable "private_subnet_tags" {}

variable "public_subnets" {}
variable "public_subnet_tags" {}

variable "database_subnets" {}
variable "database_subnet_tags" {}

variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "one_nat_gateway_per_az" {}

variable "tags" {}

# ADD
variable "create_database_subnet_route_table" {}
variable "create_database_nat_gateway_route" {}
variable "create_database_internet_gateway_route" {}
variable "create_database_subnet_group" {}