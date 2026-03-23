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

resource "helm_release" "qdrant" {
  name             = "qdrant"
  namespace        = var.namespace
  create_namespace = true

  chart = "${path.module}/charts/qdrant"

  values = [
    yamlencode({
      image = {
        repository = var.image_repository
        tag        = var.image_tag
        pullPolicy = var.image_pull_policy
      }
      service = {
        type     = "ClusterIP"
        httpPort = var.http_port
        grpcPort = var.grpc_port
      }
      persistence = {
        enabled      = var.persistence_enabled
        storageClass = var.storage_class
        size         = var.storage_size
        accessMode   = var.storage_access_mode
      }
      resources          = var.resources
      deploymentStrategy = var.deployment_strategy
    })
  ]
}
