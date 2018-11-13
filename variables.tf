############## Input from the Deployer

variable "owner" {
  description = "Owner Name"
}
variable "owner_email" {
  description = "Owner Email"
}

variable "instance_id" {
  default = "i-0eb4a487158967f54"
  description = "instance for the application"
}

variable "dso_domain" {
  default = "dsolab.net"
  description = "DSO Domain name"
}

variable "zone_id" {
 default = "/hostedzone/Z2KBAPVGPRZ50I"
 description = "Zone ID of the Domain"
}

variable "arn_acme" {
  default = "arn:aws:acm:us-east-1:757687274468:certificate/f5b34366-54c1-4814-bd9b-6a9a650238d9"
  description = "certificate arn"
}

############### Input from the LAB stack

variable "environment" {
  description = "The name of the environment"
  default = "production"
}

############### Input from the LAB stack


variable "short_env" {
  type = "map"

  default = {
    production = "hackjs"
    development = "hackjs"
  }
}

variable "key_name" {
  type = "map"

  default = {
    production = "dso-prod-10102018"
    development = "dso-dev-09102018"
  }
}


variable "sg_id" {
  type = "map"

  default = {
    production = "sg-0961c3da3977a5a7c"
    development = "sg-0fe342bca8e2bdbb3"
  }
}

variable "vpc_id" {
  type = "map"

  default = {
    production = "vpc-082f1b56314869494"
    development = "vpc-03b2e36bfe9a699f7"
  }
}

variable "public_subnets_prod" {
  type = "list"
  default =  ["subnet-07b0dc9a6cc857aa7", "subnet-004db3a8b97237878"]
}

variable "private_subnets_prod" {
  type = "list"
  default = ["subnet-0d26f005d88b4db98", "subnet-02e1f40ac58f5aa9d"]

}

variable "subnet_id" {
  description = "Subnet"
  type = "map"

  default = {
    production =  "subnet-07b0dc9a6cc857aa7"
    development =  "subnet-069fdaba976a5e0b0"
  }
}

##########################

variable "aws_region" {
  default = "us-east-1"
  description = "AWS region"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = "list"
  description = "AWS AZ"
}
