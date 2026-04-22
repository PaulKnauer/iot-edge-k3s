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

  type = "Opaque"

  data = {
    "identity_validation.reset_password.jwt.hmac.key" = var.jwt_secret
    "session.encryption.key"                          = var.session_secret
    "storage.encryption.key"                          = var.storage_encryption_key
    "identity_providers.oidc.hmac.key"                = var.oidc_hmac_secret
    "oidc.jwk.RS256.pem"                              = var.oidc_jwks_private_key
    "oidc.client.${var.oidc_client_id}.secret"        = var.oidc_client_secret_hash
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
  timeout    = var.helm_timeout_seconds

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
        strategy = {
          type = "Recreate"
        }
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
          cookies = [
            {
              domain                  = var.domain
              subdomain               = var.authelia_subdomain
              default_redirection_url = var.default_redirection_url
            }
          ]
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

        identity_providers = {
          oidc = {
            enabled = var.oidc_enabled
            hmac_secret = {
              path = "identity_providers.oidc.hmac.key"
            }
            jwks = [
              {
                key_id    = "main"
                algorithm = "RS256"
                use       = "sig"
                key = {
                  path = "/secrets/${kubernetes_secret_v1.authelia_secrets.metadata[0].name}/oidc.jwk.RS256.pem"
                }
              }
            ]
            clients = [
              {
                client_id   = var.oidc_client_id
                client_name = var.oidc_client_name
                client_secret = {
                  path = "/secrets/${kubernetes_secret_v1.authelia_secrets.metadata[0].name}/oidc.client.${var.oidc_client_id}.secret"
                }
                grant_types = var.oidc_client_grant_types
                scopes      = var.oidc_client_scopes

                authorization_policy = var.oidc_client_authorization_policy
              }
            ]
          }
        }
      }

      secret = {
        existingSecret = kubernetes_secret_v1.authelia_secrets.metadata[0].name
        additionalSecrets = {
          (kubernetes_secret_v1.authelia_secrets.metadata[0].name) = {
            items = [
              {
                key  = "oidc.jwk.RS256.pem"
                path = "oidc.jwk.RS256.pem"
              },
              {
                key  = "oidc.client.${var.oidc_client_id}.secret"
                path = "oidc.client.${var.oidc_client_id}.secret"
              }
            ]
          }
        }
      }
    })
  ]
}
