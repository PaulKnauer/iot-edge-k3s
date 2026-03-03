terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = var.ingress_namespace
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version

  values = [
    yamlencode({
      controller = {
        service = {
          type = "NodePort"
          nodePorts = {
            http  = var.http_node_port
            https = var.https_node_port
          }
        }
        extraArgs = {
          default-ssl-certificate = "${var.ingress_namespace}/homelab-tls"
        }
      }
    })
  ]

  timeout = var.helm_timeout_seconds
}

resource "null_resource" "cert_and_ingress" {
  triggers = {
    node_ip = var.node_ip
    domain  = var.domain
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      export KUBECONFIG="${var.kubeconfig_path}"

      echo "Waiting for ingress-nginx controller to be ready..."
      kubectl rollout status deployment/ingress-nginx-controller \
        -n ${var.ingress_namespace} --timeout=180s

      echo "Applying homelab TLS certificate..."
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: homelab-tls
  namespace: ${var.ingress_namespace}
spec:
  secretName: homelab-tls
  issuerRef:
    name: homelab-ca-issuer
    kind: ClusterIssuer
  dnsNames:
    - clock.${var.domain}
    - nodered.${var.domain}
    - registry.${var.domain}
  ipAddresses:
    - ${var.node_ip}
EOF

      echo "Waiting for TLS certificate to be issued..."
      kubectl wait certificate/homelab-tls \
        -n ${var.ingress_namespace} --for=condition=Ready --timeout=120s

      echo "Applying clock-server Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: clock-server
  namespace: ${var.clock_server_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: clock.${var.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.clock_server_service}
                port:
                  number: ${var.clock_server_port}
EOF

      echo "Applying nodered Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nodered
  namespace: ${var.nodered_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
spec:
  ingressClassName: nginx
  rules:
    - host: nodered.${var.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.nodered_service}
                port:
                  number: ${var.nodered_port}
EOF

      echo "Applying registry Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: registry
  namespace: ${var.registry_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
spec:
  ingressClassName: nginx
  rules:
    - host: registry.${var.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.registry_service}
                port:
                  number: ${var.registry_port}
EOF

      echo "HTTPS ingress setup complete."
      echo ""
      echo "Add to /etc/hosts on each client machine:"
      echo "  ${var.node_ip}  clock.${var.domain} nodered.${var.domain} registry.${var.domain}"
      echo ""
      echo "Access via:"
      echo "  https://clock.${var.domain}:${var.https_node_port}"
      echo "  https://nodered.${var.domain}:${var.https_node_port}"
      echo "  https://registry.${var.domain}:${var.https_node_port}"
      echo ""
      echo "Export CA cert to trust it:"
      echo "  kubectl get secret homelab-ca-tls -n cert-manager -o jsonpath='{.data.tls\\.crt}' | base64 -d > homelab-ca.crt"
    EOT
  }

  depends_on = [helm_release.ingress_nginx]
}
