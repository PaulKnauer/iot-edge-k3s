terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "helm_release" "nodered" {
  name             = "nodered"
  namespace        = var.namespace
  create_namespace = true

  chart = "${path.module}/charts/nodered"

  values = [
    yamlencode({
      image = {
        repository = var.image_repository
        tag        = var.image_tag
        pullPolicy = var.image_pull_policy
      }
      service = {
        type     = var.service_type
        port     = var.service_port
        nodePort = var.node_port
      }
      persistence = {
        enabled      = var.persistence_enabled
        storageClass = var.storage_class
        size         = var.storage_size
        accessMode   = var.storage_access_mode
      }
      resources                = var.resources
      podSecurityContext       = var.pod_security_context
      containerSecurityContext = var.container_security_context
      deploymentStrategy       = var.deployment_strategy
      env = {
        enableProjects       = var.projects_enabled
        credentialSecretName = var.credential_secret_name
        credentialSecretKey  = var.credential_secret_key
      }
    })
  ]
}
