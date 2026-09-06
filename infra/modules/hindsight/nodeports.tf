# Dedicated LAN endpoints; the upstream 0.8.2 chart ignores service.nodePort.
variable "nodeport_enabled" {
  description = "Expose API and dashboard directly over LAN HTTP."
  type        = bool
  default     = false
}

variable "api_node_port" {
  type    = number
  default = 31888
  validation {
    condition     = var.api_node_port >= 30000 && var.api_node_port <= 32767 && floor(var.api_node_port) == var.api_node_port
    error_message = "API NodePort must be an integer between 30000 and 32767."
  }
}

variable "control_plane_node_port" {
  type    = number
  default = 31889
  validation {
    condition     = var.control_plane_node_port >= 30000 && var.control_plane_node_port <= 32767 && floor(var.control_plane_node_port) == var.control_plane_node_port
    error_message = "Dashboard NodePort must be an integer between 30000 and 32767."
  }
}

resource "kubernetes_service_v1" "lan" {
  for_each = var.nodeport_enabled ? {
    api           = { port = 8888, node_port = var.api_node_port }
    control-plane = { port = var.control_plane_port, node_port = var.control_plane_node_port }
  } : {}

  metadata {
    name      = "hindsight-${each.key}-lan"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      "app.kubernetes.io/name"      = "hindsight"
      "app.kubernetes.io/instance"  = helm_release.hindsight.name
      "app.kubernetes.io/component" = each.key
    }
    port {
      name        = "http"
      port        = each.value.port
      target_port = "http"
      node_port   = each.value.node_port
      protocol    = "TCP"
    }
  }
}
