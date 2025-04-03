data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "azs" {}

data "aws_iam_policy" "administrator" {
  name = "AdministratorAccess"
}

data "aws_route53_zone" "intermediate_domain" {
  name         = "${var.domain_type}.${var.deploy_stage}.${var.root_domain}"
  private_zone = false
}

data "aws_secretsmanager_secret" "letsencrypt" {
  name = var.letsencrypt_secret
}

data "aws_secretsmanager_secret_version" "letsencrypt" {
  secret_id = data.aws_secretsmanager_secret.letsencrypt.id
}
