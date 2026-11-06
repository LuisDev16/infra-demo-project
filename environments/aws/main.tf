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
