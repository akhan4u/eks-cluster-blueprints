data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "azs" {}

data "aws_iam_policy" "administrator" {
  name = "AdministratorAccess"
}

data "aws_route53_zone" "bootstrap_domain" {
  name = var.root_domain
}
