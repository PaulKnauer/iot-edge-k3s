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

resource "kubernetes_namespace_v1" "n8n" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "n8n" {
  name      = "n8n"
  namespace = kubernetes_namespace_v1.n8n.metadata[0].name

  chart   = "${path.module}/charts/n8n"
  timeout = 600

  depends_on = [kubernetes_secret_v1.encryption_key]

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
      resources          = var.resources
      deploymentStrategy = var.deployment_strategy
      env = {
        timezone                = var.timezone
        protocol                = var.protocol
        encryptionKeySecretName = var.encryption_key_secret_name
        encryptionKeySecretKey  = var.encryption_key_secret_key
        secureCookie            = var.secure_cookie
        webhookUrl              = var.webhook_url
      }
    })
  ]
}
