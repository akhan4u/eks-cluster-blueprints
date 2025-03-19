output "eks_connect" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
}

output "harbor_iam_user" {
  description = "Harbor's IAM User for S3 Access"
  value       = aws_iam_user.harbor.name
}

output "harbor_iam_user_login_password" {
  description = "Harbor IAM User password for AWS console access (Set new password on first login)"
  value       = data.pgp_decrypt.harbor.plaintext
  sensitive   = false
}

output "harbor_ui_admin_password" {
  description = "Harbor UI Admin Password"
  value       = random_password.harbor_admin_password.result
  sensitive   = true
}

output "harbor_s3_bucket" {
  description = "Harbor S3 Bucket for storing HelmChart & Image Artifacts"
  value       = aws_s3_bucket.harbor.id
}

output "harbor_iam_user_secretmanager_secret" {
  description = "Name of the SecretManager Secret containing Harbor IAM User credentials"
  value       = aws_secretsmanager_secret.harbor_iam_user_keys.name
}

output "harbor_rds_pg_master_connection_secretmanager_secret" {
  description = "Name of the SecretManager Secret containing Harbor RDS DB Instance credentials"
  value       = aws_secretsmanager_secret.harbor_pg_master_connection.name
}
