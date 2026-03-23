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

resource "kubernetes_namespace_v1" "authelia" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "authelia_secrets" {
  metadata {
    name      = "authelia-secrets"
    namespace = kubernetes_namespace_v1.authelia.metadata[0].name
  }

  data = {
    JWT_TOKEN              = var.jwt_secret
    SESSION_ENCRYPTION_KEY = var.session_secret
    STORAGE_ENCRYPTION_KEY = var.storage_encryption_key
  }
}

resource "kubernetes_config_map_v1" "users_database" {
  metadata {
    name      = "authelia-users"
    namespace = kubernetes_namespace_v1.authelia.metadata[0].name
  }

  data = {
    "users_database.yml" = yamlencode({
      users = {
        admin = {
          displayname = "Admin"
          password    = var.admin_password_hash
          email       = "admin@${var.domain}"
          groups      = ["admins", "dev"]
        }
      }
    })
  }
}

resource "helm_release" "authelia" {
  name       = "authelia"
  namespace  = kubernetes_namespace_v1.authelia.metadata[0].name
  repository = "https://charts.authelia.com"
  chart      = "authelia"
  version    = var.chart_version

  depends_on = [
    kubernetes_secret_v1.authelia_secrets,
    kubernetes_config_map_v1.users_database,
  ]

  values = [
    yamlencode({
      domain = var.domain

      ingress = {
        enabled = false
      }

      pod = {
        kind     = "Deployment"
        replicas = 1
        extraVolumes = [
          {
            name = "users-database"
            configMap = {
              name = kubernetes_config_map_v1.users_database.metadata[0].name
            }
          }
        ]
        extraVolumeMounts = [
          {
            name      = "users-database"
            mountPath = "/config/users_database.yml"
            subPath   = "users_database.yml"
            readOnly  = true
          }
        ]
      }

      service = {
        type     = "NodePort"
        port     = 9091
        nodePort = var.node_port
      }

      persistence = {
        enabled      = true
        storageClass = var.storage_class
        size         = var.storage_size
        accessMode   = "ReadWriteOnce"
      }

      configMap = {
        enabled = true

        session = {
          domain = var.domain
          redis = {
            enabled = false
          }
        }

        storage = {
          local = {
            enabled = true
            path    = "/config/db.sqlite3"
          }
          postgres = {
            enabled = false
          }
          mysql = {
            enabled = false
          }
        }

        notifier = {
          disable_startup_check = true
          filesystem = {
            enabled  = true
            filename = "/tmp/notification.txt"
          }
          smtp = {
            enabled = false
          }
        }

        authentication_backend = {
          file = {
            enabled = true
            path    = "/config/users_database.yml"
          }
          ldap = {
            enabled = false
          }
        }

        access_control = {
          default_policy = "one_factor"
          rules          = []
        }

        totp = {
          disable = false
        }

        webauthn = {
          disable = false
        }
      }

      secret = {
        existingSecret = kubernetes_secret_v1.authelia_secrets.metadata[0].name
        jwt = {
          key = "JWT_TOKEN"
        }
        session = {
          key = "SESSION_ENCRYPTION_KEY"
        }
        storageEncryptionKey = {
          key = "STORAGE_ENCRYPTION_KEY"
        }
      }
    })
  ]
}
