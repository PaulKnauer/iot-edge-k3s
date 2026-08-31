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

locals {
  api_env = merge(
    {
      HINDSIGHT_API_WORKER_ID            = var.worker_id
      HINDSIGHT_API_STARTUP_WAIT_SECONDS = "600"
    },
    var.llm_provider != "" ? { HINDSIGHT_API_LLM_PROVIDER = var.llm_provider } : {},
    var.llm_model != "" ? { HINDSIGHT_API_LLM_MODEL = var.llm_model } : {},
    var.llm_base_url != "" ? { HINDSIGHT_API_LLM_BASE_URL = var.llm_base_url } : {},
    var.mcp_auth_token != "" ? { HINDSIGHT_API_MCP_AUTH_TOKEN = var.mcp_auth_token } : {},
    var.tenant_api_key != "" ? {
      HINDSIGHT_API_TENANT_EXTENSION = "hindsight_api.extensions.builtin.tenant:ApiKeyTenantExtension"
    } : {}
  )

  api_secrets = merge(
    var.llm_api_key != "" ? { HINDSIGHT_API_LLM_API_KEY = var.llm_api_key } : {},
    var.tenant_api_key != "" ? { HINDSIGHT_API_TENANT_API_KEY = var.tenant_api_key } : {}
  )

  control_plane_secrets = merge(
    var.control_plane_access_key != "" ? { HINDSIGHT_CP_ACCESS_KEY = var.control_plane_access_key } : {},
    var.tenant_api_key != "" ? { HINDSIGHT_CP_DATAPLANE_API_KEY = var.tenant_api_key } : {}
  )
}

resource "helm_release" "hindsight" {
  name             = "hindsight"
  namespace        = var.namespace
  create_namespace = true

  repository = "oci://ghcr.io/vectorize-io/charts"
  chart      = "hindsight"
  version    = var.chart_version

  values = [
    yamlencode({
      api = {
        env     = local.api_env
        secrets = local.api_secrets
        livenessProbe = {
          initialDelaySeconds = 420
        }
      }
      controlPlane = {
        enabled = true
        env = {
          NODE_ENV          = "production"
          HINDSIGHT_CP_PORT = tostring(var.control_plane_port)
        }
        secrets = local.control_plane_secrets
      }
      postgresql = {
        enabled = true
        auth = {
          username = var.postgresql_username
          password = var.postgresql_password
          database = var.postgresql_database
        }
        persistence = {
          enabled      = true
          storageClass = var.storage_class
          size         = var.storage_size
        }
      }
      ingress = {
        enabled   = var.ingress_enabled
        className = var.ingress_class_name
        annotations = {
          "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
          "nginx.ingress.kubernetes.io/proxy-body-size"    = var.ingress_proxy_body_size
          "nginx.ingress.kubernetes.io/proxy-read-timeout" = tostring(var.ingress_proxy_read_timeout_seconds)
          "nginx.ingress.kubernetes.io/proxy-send-timeout" = tostring(var.ingress_proxy_send_timeout_seconds)
        }
        hosts = [
          {
            host = var.web_host
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                service  = "controlPlane"
              }
            ]
          },
          {
            host = var.api_host
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                service  = "api"
              }
            ]
          }
        ]
        tls = []
      }
    })
  ]

  timeout = var.helm_timeout_seconds
}
