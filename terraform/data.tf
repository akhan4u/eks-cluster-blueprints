data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "azs" {}

data "aws_iam_policy" "administrator" {
  name = "AdministratorAccess"
}

data "aws_acm_certificate" "wildcard" {
  domain = "ignitescale.com"
}

data "aws_route53_zone" "bootstrap_domain" {
  name = var.root_domain
}

# Discover the Cluster Token for Auth
data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks.cluster_id]
  name       = module.eks.cluster_name
}
