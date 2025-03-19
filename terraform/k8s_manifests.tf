resource "kubectl_manifest" "harbor_namespace" {
  yaml_body  = templatefile("${path.module}/config/namespace.yaml", {})
  depends_on = [module.eks_blueprints_addons]
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = templatefile("${path.module}/config/cluster_secret_store.yaml", {
    region               = var.aws_region
    service_account_name = local.external_secrets_output.serviceAccount.name
    namespace            = module.eks_blueprints_addons.external_secrets.namespace
  })
  depends_on = [kubectl_manifest.harbor_namespace]
}

resource "kubectl_manifest" "harbor_s3_external_secret" {
  yaml_body = templatefile("${path.module}/config/s3_external_secret.yaml", {
    namespace            = kubectl_manifest.harbor_namespace.name
    cluster_secret_store = kubectl_manifest.cluster_secret_store.name
    harbor_iam_secret    = aws_secretsmanager_secret.harbor_iam_user_keys.name
  })
  depends_on = [kubectl_manifest.cluster_secret_store]
}

resource "kubectl_manifest" "harbor_rds_external_secret" {
  yaml_body = templatefile("${path.module}/config/rds_external_secret.yaml", {
    namespace            = kubectl_manifest.harbor_namespace.name
    cluster_secret_store = kubectl_manifest.cluster_secret_store.name
    harbor_rds_secret    = aws_secretsmanager_secret.harbor_pg_master_connection.name
  })
  depends_on = [kubectl_manifest.harbor_s3_external_secret]
}
