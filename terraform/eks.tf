# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  # Terraform Identity is 'arn:aws:iam::730335630279:role/spacelift-shared-services' Attached policy 'AmazonEKSClusterAdminPolicy'
  # Need to discuss if we need to enable this option
  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  eks_managed_node_groups = {
    "shared-services-${var.deploy_stage}" = {
      instance_types = [var.instance_type]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

}

# Below are IRSA definitions for various Kubernetes Controllers
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name             = "${local.cluster_name}-irsa-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
