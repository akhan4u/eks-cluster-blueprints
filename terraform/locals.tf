locals {
  cluster_name            = "shared-services-${var.deploy_stage}"
  cluster_version         = "1.32"
  external_secrets_output = jsondecode(module.eks_blueprints_addons.external_secrets.values)
}
