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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    helm = {
      source  = "registry.terraform.io/hashicorp/helm"
      version = "2.17.0"
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

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}
