resource "kubernetes_secret_v1" "encryption_key" {
  metadata {
    name      = var.encryption_key_secret_name
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
  }

  depends_on = [kubernetes_namespace_v1.n8n]

  type = "Opaque"

  data = {
    (var.encryption_key_secret_key) = base64encode(var.encryption_key)
  }
}
