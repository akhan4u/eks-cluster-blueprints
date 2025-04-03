# Documentation: https://registry.terraform.io/modules/aws-ia/eks-blueprints-addon/aws/latest
module "harbor" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart         = "harbor"
  chart_version = "1.16.2"
  repository    = "https://helm.goharbor.io"
  description   = "Harbor helm Chart deployment configuration"
  namespace     = "harbor"
  values = [templatefile("${path.module}/helm_values/harbor.yaml", {
    aws_region                 = var.aws_region
    database_name              = aws_db_instance.harbor.db_name
    db_host                    = aws_db_instance.harbor.address
    db_instance_username       = aws_db_instance.harbor.username
    db_port                    = aws_db_instance.harbor.port
    domain_name                = local.harbor_endpoint
    harbor_acm_certificate_arn = aws_acm_certificate.harbor.arn
    harbor_ui_password         = random_password.harbor_admin_password.result
    ingress_class              = local.alb_ingress_class
    ingress_controller         = local.alb_ingress_class
    rds_secret_name            = local.harbor_rds_external_secret_output.spec.target.name
    s3_bucket_name             = aws_s3_bucket.harbor.id
    s3_secret_name             = local.harbor_s3_external_secret_output.spec.target.name
    terraform_gitpath          = var.terraform_gitpath
  })]
}
