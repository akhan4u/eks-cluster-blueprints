# Documentation: https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest
resource "kubectl_manifest" "gp3_storage_class" {
  yaml_body  = templatefile("${path.module}/manifests/storage_class.yaml", {})
  depends_on = [module.eks_blueprints_addons]
}

resource "kubectl_manifest" "harbor_namespace" {
  yaml_body  = templatefile("${path.module}/manifests/namespace.yaml", {})
  depends_on = [kubectl_manifest.gp3_storage_class]
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = templatefile("${path.module}/manifests/cluster_secret_store.yaml", {
    region               = var.aws_region
    service_account_name = local.external_secrets_output.serviceAccount.name
    namespace            = module.eks_blueprints_addons.external_secrets.namespace
  })
  depends_on = [kubectl_manifest.harbor_namespace]
}

resource "kubectl_manifest" "harbor_s3_external_secret" {
  yaml_body = templatefile("${path.module}/manifests/s3_external_secret.yaml", {
    namespace            = kubectl_manifest.harbor_namespace.name
    cluster_secret_store = kubectl_manifest.cluster_secret_store.name
    harbor_iam_secret    = aws_secretsmanager_secret.harbor_iam_user_keys.name
  })
  depends_on = [kubectl_manifest.cluster_secret_store]
}

resource "kubectl_manifest" "harbor_rds_external_secret" {
  yaml_body = templatefile("${path.module}/manifests/rds_external_secret.yaml", {
    namespace            = kubectl_manifest.harbor_namespace.name
    cluster_secret_store = kubectl_manifest.cluster_secret_store.name
    harbor_rds_secret    = aws_secretsmanager_secret.harbor_pg_master_connection.name
  })
  depends_on = [kubectl_manifest.harbor_s3_external_secret]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = templatefile("${path.module}/manifests/cluster_issuer.yaml", {
    letsencrypt_account_email = local.letsencrypt_account
    dns_zone                  = data.aws_route53_zone.intermediate_domain.name
    dns_zone_id               = data.aws_route53_zone.intermediate_domain.zone_id
    region                    = var.aws_region
    cert_manager_irsa         = local.cert_manager_output.serviceAccount.annotations["eks.amazonaws.com/role-arn"]
    service_account_name      = local.cert_manager_output.serviceAccount.name
  })
  depends_on = [kubectl_manifest.harbor_rds_external_secret]
}

resource "kubectl_manifest" "harbor_alert_rules" {
  yaml_body  = templatefile("${path.module}/manifests/harbor_rules.yaml", {})
  depends_on = [kubectl_manifest.cluster_issuer]
}
