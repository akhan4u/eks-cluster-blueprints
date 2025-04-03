# Documentation: https://registry.terraform.io/modules/aws-ia/eks-blueprints-addon/aws/latest
module "betterstack" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart            = "betterstack-logs"
  chart_version    = "1.1.6"
  repository       = "https://betterstackhq.github.io/logs-helm-chart"
  description      = "BetterStack helm Chart deployment configuration"
  namespace        = "betterstack"
  create_namespace = true
  values = [templatefile("${path.module}/helm_values/betterstack.yaml", {
    betterstack_ingestion_host    = var.betterstack_ingestion_host
    betterstack_logs_source_token = var.betterstack_logs_source_token
  })]
}
