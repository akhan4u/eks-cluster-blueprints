# Create AWS EKS Cluster using EKS Blueprints

This repo creates an EKS cluster with EKS blueprints using terraform. It creates necessary services and also deploys below applications using EKS blueprint addon's.

* External DNS
* External Secrets
* Cert Manager
* Harbor
* Nginx Ingress
* ALB Ingress Controller


Addons to be deployed via EKS module include

* Metrics Server
* KubeProxy
* AWS VPC CNI
* AWS EBS CSI Driver
* Core DNS
* AWS EKS Pod Identity Agent (Optional)
