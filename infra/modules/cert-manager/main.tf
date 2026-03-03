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

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version

  values = [
    yamlencode({
      crds = {
        enabled = true
      }
    })
  ]

  timeout = var.helm_timeout_seconds
}

resource "null_resource" "issuers" {
  triggers = {
    chart_version = var.chart_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      export KUBECONFIG="${var.kubeconfig_path}"

      echo "Waiting for cert-manager webhook to be ready..."
      kubectl rollout status deployment/cert-manager-webhook \
        -n ${var.namespace} --timeout=180s

      echo "Applying bootstrap self-signed ClusterIssuer..."
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-bootstrap
spec:
  selfSigned: {}
EOF

      echo "Applying homelab CA Certificate..."
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: homelab-ca
  namespace: ${var.namespace}
spec:
  isCA: true
  commonName: homelab-ca
  secretName: homelab-ca-tls
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-bootstrap
    kind: ClusterIssuer
    group: cert-manager.io
EOF

      echo "Waiting for CA certificate to be issued..."
      kubectl wait certificate/homelab-ca \
        -n ${var.namespace} --for=condition=Ready --timeout=120s

      echo "Applying CA ClusterIssuer..."
      kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: homelab-ca-issuer
spec:
  ca:
    secretName: homelab-ca-tls
EOF

      echo "cert-manager issuers ready."
    EOT
  }

  depends_on = [helm_release.cert_manager]
}
