resource "kubernetes_secret_v1" "encryption_key" {
  metadata {
    name      = var.encryption_key_secret_name
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    (var.encryption_key_secret_key) = base64encode(var.encryption_key)
  }
}
