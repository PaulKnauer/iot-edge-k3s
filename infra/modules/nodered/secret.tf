resource "kubernetes_secret_v1" "credential_secret" {
  metadata {
    name      = var.credential_secret_name
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    (var.credential_secret_key) = base64encode(var.credential_secret)
  }
}
