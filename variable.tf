#forcing user to provide input
variable "cidr_block" {

    
  
}

variable "enable_dns_hostnames" {

    default = true
  
}

variable "enable_dns_support" {

    default = true
  
}

variable "default_tags" {

    default = {}
    # Name = "roboshop"
    # Environment = "DEV"
    # Terraform = True
  
}

variable "vpc_tags" {
  default = {}
  #Name = "roboshop"
}

variable "ig_tags" {
  default = {}
}

variable "public_subnet_cidr" {
  
    type =list
    validation {
      condition = length(var.public_subnet_cidr)==2
      error_message = "pls pass only 2 input cidr"

    }
}

variable "public_subnet_tags" {
   
   Name = "roboshop"
}

variable "private_subnet_cidr" {
  
    type =list
    validation {
      condition = length(var.priavte_subnet_cidr)==2
      error_message = "pls pass only 2 input cidr"

    }
}

variable "private_subnet_tags" {
   
   Name = "roboshop"
}

variable "database_subnet_cidr" {
  
    type =list
    validation {
      condition = length(var.database_subnet_cidr)==2
      error_message = "pls pass only 2 input cidr"

    }
}

variable "database_subnet_tags" {
   
   Name = "roboshop"
}


variable "nat_gateway_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {}
}

variable "db_subnet_group_tags" {
  default = {}
}