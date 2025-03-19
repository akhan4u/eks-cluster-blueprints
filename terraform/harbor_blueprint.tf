module "eks_blueprints_addon" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  chart         = "harbor"
  chart_version = "1.16.2"
  repository    = "https://helm.goharbor.io"
  description   = "Harbor helm Chart deployment configuration"
  namespace     = "harbor"

  values = [
    <<-EOT
      expose:
        type: ingress
        tls:
          enabled: true
          certSource: none
        ingress:
          hosts:
            core: harbor.ignitescale.com
          controller: default
          className: "${local.ingress_nginx_output.controller.ingressClassResource.name}"
          annotations:
            ingress.kubernetes.io/ssl-redirect: "true"
            ingress.kubernetes.io/proxy-body-size: "0"
            nginx.ingress.kubernetes.io/ssl-redirect: "true"
            nginx.ingress.kubernetes.io/proxy-body-size: "0"
            external-dns.alpha.kubernetes.io/hostname: harbor.ignitescale.com
            service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${data.aws_acm_certificate.wildcard.arn}"
      externalURL: https://harbor.ignitescale.com
      persistence:
        enabled: false
        resourcePolicy: "keep"
        persistentVolumeClaim:
          redis:
            storageClass: "gp2"
            accessMode: ReadWriteOnce
            size: 1Gi
          trivy:
            storageClass: "gp2"
            accessMode: ReadWriteOnce
            size: 5Gi
        imageChartStorage:
          disableredirect: false
          type: s3
          s3:
            # Set an existing secret for S3 accesskey and secretkey
            # keys in the secret should be REGISTRY_STORAGE_S3_ACCESSKEY and REGISTRY_STORAGE_S3_SECRETKEY for registry
            existingSecret: ${local.harbor_s3_external_secret_output.spec.target.name}
            region: "${var.aws_region}"
            bucket: "${aws_s3_bucket.harbor.id}"
      database:
        type: external
        external:
          host: "${aws_db_instance.harbor.address}"
          port: "${aws_db_instance.harbor.port}"
          username: "${aws_db_instance.harbor.username}"
          # 'registry' database with UTF8 encoding must already exist
          coreDatabase: "${aws_db_instance.harbor.db_name}"
          # if using existing secret, the key must be "password"
          existingSecret: ${local.harbor_rds_external_secret_output.spec.target.name}
          sslmode: "require"
      metrics:
        enabled: true
        # Create prometheus serviceMonitor to scrape harbor metrics
        # This requires the monitoring.coreos.com/v1 CRD
        serviceMonitor:
          enabled: false
      jobservice:
        jobLoggers:
          - database
    EOT
  ]
}
