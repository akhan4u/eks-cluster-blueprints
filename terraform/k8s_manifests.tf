resource "kubectl_manifest" "harbor_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: harbor
YAML
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-css
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${var.aws_region}
      auth:
        jwt:
          serviceAccountRef:
            name: ${local.external_secrets_output.serviceAccount.name}
            namespace: ${module.eks_blueprints_addons.external_secrets.namespace}
YAML
}

resource "kubectl_manifest" "harbor_s3_external_secret" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: harbor-s3-external-secret
  namespace: ${kubectl_manifest.harbor_namespace.name}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${kubectl_manifest.cluster_secret_store.name}
    kind: ClusterSecretStore
  target:
    name: harbor-s3-secret
    creationPolicy: Owner
  data:
  - secretKey: REGISTRY_STORAGE_S3_ACCESSKEY
    remoteRef:
      key: ${aws_secretsmanager_secret.harbor_iam_user_keys.name}
      property: AWS_ACCESS_KEY_ID
  - secretKey: REGISTRY_STORAGE_S3_SECRETKEY
    remoteRef:
      key: ${aws_secretsmanager_secret.harbor_iam_user_keys.name}
      property: AWS_SECRET_ACCESS_KEY
YAML
}

resource "kubectl_manifest" "harbor_rds_external_secret" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: harbor-rds-external-secret
  namespace: ${kubectl_manifest.harbor_namespace.name}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${kubectl_manifest.cluster_secret_store.name}
    kind: ClusterSecretStore
  target:
    name: harbor-rds-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: ${aws_secretsmanager_secret.harbor_pg_master_connection.name}
      property: password
YAML
}
