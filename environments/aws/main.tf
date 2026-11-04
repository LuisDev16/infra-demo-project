terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  cloud {
    organization = "luisdcm"

    workspaces {
      name = "infra-demo-project-aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "git::https://github.com/LuisDev16/modulos-terraform.git//aws/network?ref=main"

  name              = var.name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
  tags              = var.tags
}
