variable "vpc_cidr" {
    default  =  "10.100.0.0/16"
    type = string
  
}

variable "vpc_name" {
    default  =  "main"
  
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}

variable "enable_dns_support" {
    type = bool
    default = true
  
}


variable "second_vpc_cidr" {
    default  =  "10.200.0.0/16"
    type = string
  
}

variable "second_vpc_name" {
    default  =  "second"
  
}

variable private_subnets_number {

    description = "The number of private subnets to create (defaults to 3 if not specified)."
    default     =  2
    type        = number
}

 

variable in_subnet_cidr_size {

    description = "use with cidersubnet function to make the subnetmask for subnets."
    default     =  8
    type        = number
}


variable "max_subnets" {
  description = "The maximum number of subnets to create"
  type        = number
  default     = 2
}