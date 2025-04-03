# Documentation: https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      # Values: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/v1.41.0/charts/aws-ebs-csi-driver/values.yaml
      configuration_values = jsonencode({
        # Disable the external-snapshotter sidecar
        sidecars = {
          snapshotter = {
            forceEnable = false
          }
        }
      })
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_metrics_server = true

  enable_external_dns = true
  external_dns = {
    name             = "external-dns"
    chart_version    = "1.15.2"
    repository       = "https://kubernetes-sigs.github.io/external-dns/"
    namespace        = "external-dns"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/external_dns.yaml", {})]
  }
  external_dns_route53_zone_arns = [data.aws_route53_zone.intermediate_domain.arn]

  enable_external_secrets = true
  external_secrets = {
    name             = "external-secrets"
    chart_version    = "0.14.4"
    repository       = "https://charts.external-secrets.io"
    namespace        = "external-secrets"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/external_secrets.yaml", {})]
  }
  external_secrets_secrets_manager_arns = [
    aws_secretsmanager_secret.harbor_pg_master_connection.arn,
    aws_secretsmanager_secret.harbor_iam_user_keys.arn
  ]

  enable_cert_manager = true
  cert_manager = {
    chart_version    = "v1.17.1"
    namespace        = "cert-manager"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/cert_manager.yaml", {})]
  }
  cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.intermediate_domain.arn]

  enable_ingress_nginx = true
  ingress_nginx = {
    name             = "ingress-nginx"
    chart_version    = "4.12.0"
    repository       = "https://kubernetes.github.io/ingress-nginx"
    namespace        = "ingress-nginx"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/ingress_nginx.yaml", {})]
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    name          = "aws-load-balancer-controller"
    chart_version = "1.12.0"
    repository    = "https://aws.github.io/eks-charts"
    namespace     = "kube-system"
    values = [templatefile("${path.module}/helm_values/aws_load_balancer_controller.yaml", {
      vpc_id = module.vpc.vpc_id
    })]
  }

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    name          = "kube-prometheus-stack"
    chart_version = "70.1.1"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = "kube-prometheus-stack"
    values = [templatefile("${path.module}/helm_values/prometheus_stack.yaml", {
      cluster_name               = local.cluster_name
      harbor_grafana_endpoint    = local.grafana_endpoint
      harbor_prometheus_endpoint = local.prometheus_endpoint
    })]
  }
}

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
