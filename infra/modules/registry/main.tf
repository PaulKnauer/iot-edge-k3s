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

resource "helm_release" "registry" {
  name             = "registry"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true

  repository = "https://twuni.github.io/docker-registry.helm"
  chart      = "docker-registry"
  version    = var.chart_version

  values = [
    yamlencode({
      replicaCount = var.replica_count
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
      updateStrategy = {
        type = "Recreate"
      }
      secrets = {
        htpasswd = var.htpasswd
      }
      configData = {
        version = 0.1
        log = {
          fields = {
            service = "registry"
          }
        }
        storage = {
          cache = {
            blobdescriptor = "inmemory"
          }
          delete = {
            enabled = true
          }
        }
        http = {
          addr = ":5000"
          headers = {
            X-Content-Type-Options = ["nosniff"]
          }
          debug = {
            addr = ":5001"
            prometheus = {
              enabled = false
              path    = "/metrics"
            }
          }
        }
        health = {
          storagedriver = {
            enabled   = true
            interval  = "10s"
            threshold = 3
          }
        }
      }
    })
  ]

  timeout = var.helm_timeout_seconds
}
