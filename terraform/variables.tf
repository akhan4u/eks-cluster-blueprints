variable "aws_region" {
  description = "The region where the infrastructure should be deployed to"
  type        = string
  default     = "us-west-1"
}

variable "root_domain" {
  description = "The TLD of the DNS to use for this deployment"
  type        = string
}

variable "domain_type" {
  description = "Intermediate domain type"
  type        = string
  default     = "c"
}

variable "letsencrypt_secret" {
  description = "The Name of AWS SecretsManager secret for LetsEncrypt Configuration"
  type        = string
}

variable "enable_vpc_endpoint" {
  description = "Enable S3 VPC Gateway Endpoint"
  type        = bool
  default     = null
}

variable "deploy_stage" {
  description = <<EOT
  The environment short name to use for the deployed resources (for tagging purposes).

  Options:
  - dev
  - chimera
  - prod

  Default: dev
  EOT
  default     = "dev"
  type        = string

  validation {
    condition     = can(regex("^dev$|^chimera$|^prod$", var.deploy_stage))
    error_message = "Error: Invalid Environment."
  }
}

variable "db_name" {
  description = "Harbor Database Name"
  type        = string
  default     = "registry"
}

variable "db_engine" {
  description = "Harbor RDS DB Engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Harbor RDS DB Engine Version"
  type        = string
  default     = "15.10"
}

variable "db_instance_type" {
  description = <<EOT
  RDS DB Instance type for Harbor

  Reference: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Support.html#gen-purpose-inst-classes

  EOT
  type        = string
}

variable "db_instance_username" {
  description = "RDS DB Instance Username for Harbor"
  type        = string
  default     = "harbor"
}

variable "db_instance_storage" {
  description = "DB Instance allocated storage in gibibytes"
  type        = number
  default     = 10
}

variable "harbor_bucket" {
  description = "Name of the S3 Bucket"
  type        = string
  default     = "harbor-test"
}

variable "harbor_iam_user" {
  description = "Harbor IAM User to access S3 Bucket"
  type        = string
  default     = "harbor"
}

variable "instance_type" {
  description = <<EOT
  AWS EKS Instance Type for Harbor

  Reference: https://goharbor.io/docs/2.12.0/install-config/installation-prereqs/
  EOT
  type        = string
}

variable "public_subnets" {
  description = "Public Subnets CIDR range"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnets CIDR range"
  type        = list(string)
}

variable "team" {
  description = "team that owns application (for tagging purposes)"
  type        = string
  default     = "ionet-k8s"
}

variable "terraform_gitpath" {
  description = "The location in source control where the terraform directory exists (for tagging purposes)"
  type        = string
  default     = "ionet-k8s/terraform-shared-services/terraform"
}

variable "vpc_name" {
  description = "VPC Name for EKS Cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for EKS Cluster"
  type        = string
}
