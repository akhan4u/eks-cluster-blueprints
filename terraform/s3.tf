resource "aws_s3_bucket" "harbor" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.harbor_bucket}"
}

data "aws_iam_policy_document" "harbor_iam_user_policy" {
  statement {
    sid    = "S3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.harbor.id}",
      "arn:aws:s3:::${aws_s3_bucket.harbor.id}/*",
    ]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
  }
}

resource "pgp_key" "harbor" {
  name    = var.harbor_iam_user
  email   = "harbor@test.com"
  comment = "Console login for Harbor"
}

resource "aws_iam_user" "harbor" {
  name = var.harbor_iam_user
}

resource "aws_iam_user_login_profile" "harbor" {
  user                    = aws_iam_user.harbor.name
  pgp_key                 = pgp_key.harbor.public_key_base64
  password_reset_required = true
}

data "pgp_decrypt" "harbor" {
  private_key         = pgp_key.harbor.private_key
  ciphertext          = aws_iam_user_login_profile.harbor.encrypted_password
  ciphertext_encoding = "base64"
}

resource "aws_iam_policy" "harbor" {
  name        = "harbor_s3_policy"
  description = "IAM User Policy to access Harbor S3 Bucket"
  policy      = data.aws_iam_policy_document.harbor_iam_user_policy.json
}

resource "aws_iam_user_policy_attachment" "harbor_s3_access" {
  user       = aws_iam_user.harbor.name
  policy_arn = aws_iam_policy.harbor.arn
}

resource "aws_iam_user_policy_attachment" "harbor_admin" {
  user       = aws_iam_user.harbor.name
  policy_arn = data.aws_iam_policy.administrator.arn
}

resource "aws_iam_access_key" "harbor" {
  user = aws_iam_user.harbor.name
}

resource "aws_secretsmanager_secret" "harbor_iam_user_keys" {
  name = "${var.deploy_stage}_iam_user_harbor"
}

resource "aws_secretsmanager_secret_version" "harbor_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.harbor_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.harbor.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.harbor.secret
  })
}
