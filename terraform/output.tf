output "eks_connect" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
}

output "harbor_iam_user" {
  description = "Harbor's IAM User for S3 Access"
  value       = aws_iam_user.harbor.name
}

output "password_harbor" {
  description = "Your password for first-time console login"
  value       = data.pgp_decrypt.harbor.plaintext
  sensitive   = false
}

output "harbor_iam_user_secretmanager_secret" {
  description = "Harbor's IAM User SecretManager Secret ARN"
  value       = aws_secretsmanager_secret.harbor_iam_user_keys.arn
}

output "harbor_s3_bucket" {
  description = "Harbor S3 Bucket"
  value       = aws_s3_bucket.harbor.id
}

output "harbor_rds_pg_master_connection" {
  description = "Harbor RDS Instance Secret Resource"
  value       = aws_secretsmanager_secret.harbor_pg_master_connection.arn
}
