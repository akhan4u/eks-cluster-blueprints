locals {
  cluster_name                      = "shared-services-${var.deploy_stage}"
  cluster_version                   = "1.32"
  ingress_nginx_output              = jsondecode(module.eks_blueprints_addons.ingress_nginx.values)
  external_secrets_output           = jsondecode(module.eks_blueprints_addons.external_secrets.values)
  harbor_s3_external_secret_output  = yamldecode(kubectl_manifest.harbor_s3_external_secret.yaml_body_parsed)
  harbor_rds_external_secret_output = yamldecode(kubectl_manifest.harbor_rds_external_secret.yaml_body_parsed)
}
