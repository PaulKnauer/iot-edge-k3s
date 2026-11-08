variable "codex_auth_file" {
  description = "Absolute path to gitignored ChatGPT OAuth auth.json; copied once into persistent writable storage."
  type        = string
  default     = ""
}

resource "kubernetes_secret_v1" "codex_auth" {
  count = local.codex_storage_enabled ? 1 : 0
  metadata {
    name      = "hindsight-codex-bootstrap"
    namespace = var.namespace
  }
  data = { "auth.json" = sensitive(file(var.codex_auth_file)) }
}

resource "kubernetes_persistent_volume_claim_v1" "codex_auth" {
  count = local.codex_storage_enabled ? 1 : 0
  metadata {
    name      = "hindsight-codex-auth"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    resources { requests = { storage = "1Gi" } }
  }
  lifecycle { prevent_destroy = true }
}

# Chart 0.8.2 supports extra mounts but not init containers. A one-time Job
# seeds the volume before Helm upgrades the API. Never overwrite rotated auth.
resource "kubernetes_job_v1" "codex_auth_bootstrap" {
  count = local.codex_storage_enabled ? 1 : 0
  metadata {
    name      = "hindsight-codex-auth-bootstrap"
    namespace = var.namespace
  }
  spec {
    backoff_limit = 2
    template {
      metadata {}
      spec {
        restart_policy = "Never"
        security_context { fs_group = 1000 }
        container {
          name    = "seed"
          image   = "busybox:1.37.0"
          command = ["sh", "-ec", "if [ ! -s /auth/auth.json ]; then umask 077; cp /seed/auth.json /auth/.auth.tmp; mv /auth/.auth.tmp /auth/auth.json; fi; chmod 600 /auth/auth.json"]
          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }
          volume_mount {
            name       = "seed"
            mount_path = "/seed"
            read_only  = true
          }
          volume_mount {
            name       = "auth"
            mount_path = "/auth"
          }
        }
        volume {
          name = "seed"
          secret { secret_name = kubernetes_secret_v1.codex_auth[0].metadata[0].name }
        }
        volume {
          name = "auth"
          persistent_volume_claim { claim_name = kubernetes_persistent_volume_claim_v1.codex_auth[0].metadata[0].name }
        }
      }
    }
  }
  wait_for_completion = true
  timeouts { create = "5m" }
}
