locals {
  alb_ingress_class                 = "alb"
  vpc_name                          = "${var.vpc_name}-${var.deploy_stage}"
  cluster_name                      = "shared-services-${var.deploy_stage}"
  cluster_version                   = "1.32"
  harbor_endpoint                   = "harbor.${data.aws_route53_zone.intermediate_domain.name}"
  grafana_endpoint                  = "harbor-grafana.${data.aws_route53_zone.intermediate_domain.name}"
  prometheus_endpoint               = "harbor-prometheus.${data.aws_route53_zone.intermediate_domain.name}"
  ingress_nginx_output              = jsondecode(module.eks_blueprints_addons.ingress_nginx.values)
  external_secrets_output           = jsondecode(module.eks_blueprints_addons.external_secrets.values)
  cert_manager_output               = jsondecode(module.eks_blueprints_addons.cert_manager.values)
  harbor_s3_external_secret_output  = yamldecode(kubectl_manifest.harbor_s3_external_secret.yaml_body_parsed)
  harbor_rds_external_secret_output = yamldecode(kubectl_manifest.harbor_rds_external_secret.yaml_body_parsed)
  letsencrypt_account               = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.letsencrypt.secret_string))["meta"]["register_to_eff"]
}
