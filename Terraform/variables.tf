variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "cidr_numeral" {
  description = "The VPC CIDR numeral 172.x.0.0/16"
}

variable "cidr_numeral_public" {
  default = {
    "0" = "0"
    "1" = "1"
    "2" = "2"
  }
}

variable "cidr_numeral_private" {
  default = {
    "0" = "3"
    "1" = "4"
    "2" = "5"
  }
}

variable "cidr_numeral_private_db" {
  default = {
    "0" = "6"
    "1" = "7"
    "2" = "8"
  }
}

variable "cidr_numeral_private_emr" {
  default = {
    "0" = "9"
    "1" = "10"
    "2" = "11"
  }
}


variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
}
