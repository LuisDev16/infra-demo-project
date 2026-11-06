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

# BEGIN ISSUE COPILOT: 3
module "network_issue_3" {
  source      = "git::https://github.com/LuisDev16/modulos-terraform.git//aws/network?ref=fa2a8482436be6938c90f34846d77181bdc64c7d"
  name        = "vpc-dev-01"
  vpc_cidr    = "10.20.0.0/16"
  subnet_cidr = "10.20.1.0/24"
  tags        = { "Environment" = "dev", "ManagedBy" = "infra-demo-issue-copilot", "RequestIssue" = "3" }
}
# END ISSUE COPILOT: 3

# BEGIN ISSUE COPILOT: 7
module "network_issue_7" {
  source      = "git::https://github.com/LuisDev16/modulos-terraform.git//aws/network?ref=fa2a8482436be6938c90f34846d77181bdc64c7d"
  name        = "vpc-qa-01"
  vpc_cidr    = "10.30.0.0/16"
  subnet_cidr = "10.30.1.0/24"
  tags        = { "Environment" = "staging" }
}
# END ISSUE COPILOT: 7
