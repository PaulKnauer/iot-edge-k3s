terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = var.chart_version

  values = [
    yamlencode(var.values)
  ]
}
