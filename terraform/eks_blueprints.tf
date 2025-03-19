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
    # Values: https://github.com/kubernetes-sigs/external-dns/blob/external-dns-helm-chart-1.15.2/charts/external-dns/values.yaml
    values = [
      <<-EOT
      provider:
      name: aws
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${module.external_dns_irsa.iam_role_arn}
    EOT
    ]
  }
  external_dns_route53_zone_arns = [data.aws_route53_zone.bootstrap_domain.arn]

  enable_external_secrets = true
  external_secrets = {
    name             = "external-secrets"
    chart_version    = "0.14.4"
    repository       = "https://charts.external-secrets.io"
    namespace        = "external-secrets"
    create_namespace = true
    # Values: https://github.com/external-secrets/external-secrets/blob/helm-chart-0.14.4/deploy/charts/external-secrets/values.yaml
    values = [
      <<-EOT
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${module.external_secrets_irsa.iam_role_arn}
    EOT
    ]
  }

  enable_cert_manager = true
  cert-manager = {
    chart_version    = "v1.17.1"
    namespace        = "cert-manager"
    create_namespace = true
    # Values: https://github.com/cert-manager/cert-manager/blob/v1.17.1/deploy/charts/cert-manager/values.yaml
    values = [
      <<-EOT
      crds:
        enabled: true
      serviceAccount:
        create: true
        name: cert-manager-acme-dns01-route53
        annotations:
          eks.amazonaws.com/role-arn: ${module.cert_manager_irsa.iam_role_arn}
      # the securityContext is required, so the pod can access files required to assume the IAM role
      securityContext:
        fsGroup: 1001
    EOT
    ]
  }
  cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.bootstrap_domain.arn]

  enable_ingress_nginx = true
  ingress_nginx = {
    name             = "ingress-nginx"
    chart_version    = "4.12.0"
    repository       = "https://kubernetes.github.io/ingress-nginx"
    namespace        = "ingress-nginx"
    create_namespace = true
    # Values: https://github.com/kubernetes/ingress-nginx/blob/helm-chart-4.12.0/charts/ingress-nginx/values.yaml
    values = [templatefile("${path.module}/helm_values/ingres_nginx.yaml", {})]
  }
}
