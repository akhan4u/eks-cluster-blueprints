terraform {
  required_version = "1.9.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    pgp = {
      source  = "ekristen/pgp"
      version = "0.2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      deploy_stage      = var.deploy_stage
      team              = var.team
      terraform_gitpath = var.terraform_gitpath
    }
  }
}

provider "pgp" {}
