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
    node_ip             = var.node_ip
    node_dns_names      = join(",", var.node_dns_names)
    domain              = var.domain
    https_node_port     = var.https_node_port
    ingress_tls_secret  = "homelab-tls"
    authelia_namespace  = var.authelia_namespace
    sonos_mcp_namespace = var.sonos_mcp_namespace
    sonos_mcp_hosts     = join(",", concat(["sonos-mcp.${var.domain}"], var.sonos_mcp_extra_hosts))
    mqtt_mcp_namespace  = var.mqtt_mcp_namespace
    mqtt_mcp_hosts      = join(",", concat(["mqtt-mcp.${var.domain}"], var.mqtt_mcp_extra_hosts))
    hindsight_namespace = var.hindsight_namespace
    hindsight_web_host  = var.hindsight_web_host
    hindsight_api_host  = var.hindsight_api_host
    # Re-run the kubectl apply whenever the rendered manifests in this module
    # change (e.g. ingress annotations), so edits here reconcile via terragrunt
    # instead of requiring a manual taint/replace.
    manifests_hash = filesha256("${path.module}/main.tf")
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
    - registry.${var.domain}
    - authelia.${var.domain}
    - sonos-mcp.${var.domain}
    - mqtt-mcp.${var.domain}
    - ${var.hindsight_web_host}
    - ${var.hindsight_api_host}
%{for name in var.node_dns_names~}
    - ${name}
%{endfor~}
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
    nginx.ingress.kubernetes.io/auth-url: "http://authelia.${var.authelia_namespace}.svc.cluster.local:9091/api/authz/auth-request"
    nginx.ingress.kubernetes.io/auth-signin: "https://authelia.${var.domain}:${var.https_node_port}/?rd=https://\$host:${var.https_node_port}\$request_uri"
    nginx.ingress.kubernetes.io/auth-response-headers: "Remote-User,Remote-Groups,Remote-Name,Remote-Email"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - clock.${var.domain}
      secretName: homelab-tls
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
  tls:
    - hosts:
        - registry.${var.domain}
      secretName: homelab-tls
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

      echo "Applying Authelia Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: authelia
  namespace: ${var.authelia_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - authelia.${var.domain}
      secretName: homelab-tls
  rules:
    - host: authelia.${var.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.authelia_service}
                port:
                  number: 9091
EOF

      echo "Applying sonos-mcp Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sonos-mcp
  namespace: ${var.sonos_mcp_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
%{for host in concat(["sonos-mcp.${var.domain}"], var.sonos_mcp_extra_hosts)~}
        - ${host}
%{endfor~}
      secretName: homelab-tls
  rules:
%{for host in concat(["sonos-mcp.${var.domain}"], var.sonos_mcp_extra_hosts)~}
    - host: ${host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.sonos_mcp_service}
                port:
                  number: ${var.sonos_mcp_port}
%{endfor~}
EOF

      echo "Applying mqtt-mcp Ingress..."
      kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mqtt-mcp
  namespace: ${var.mqtt_mcp_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
%{for host in concat(["mqtt-mcp.${var.domain}"], var.mqtt_mcp_extra_hosts)~}
        - ${host}
%{endfor~}
      secretName: homelab-tls
  rules:
%{for host in concat(["mqtt-mcp.${var.domain}"], var.mqtt_mcp_extra_hosts)~}
    - host: ${host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${var.mqtt_mcp_service}
                port:
                  number: ${var.mqtt_mcp_port}
%{endfor~}
EOF

      if kubectl get ingress hindsight -n ${var.hindsight_namespace} >/dev/null 2>&1; then
        echo "Hindsight ingress already managed in-cluster; skipping duplicate hindsight-web/hindsight-api apply."
      else
        echo "Applying hindsight web Ingress..."
        kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hindsight-web
  namespace: ${var.hindsight_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - ${var.hindsight_web_host}
      secretName: homelab-tls
  rules:
    - host: ${var.hindsight_web_host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hindsight-hindsight-control-plane
                port:
                  number: 3000
EOF

        echo "Applying hindsight API Ingress..."
        kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hindsight-api
  namespace: ${var.hindsight_namespace}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - ${var.hindsight_api_host}
      secretName: homelab-tls
  rules:
    - host: ${var.hindsight_api_host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hindsight-hindsight-api
                port:
                  number: 8888
EOF
      fi

      echo "HTTPS ingress setup complete."
      echo ""
      echo "Add to /etc/hosts on each client machine:"
      echo "  ${var.node_ip}  clock.${var.domain} registry.${var.domain} authelia.${var.domain} sonos-mcp.${var.domain} mqtt-mcp.${var.domain} ${var.hindsight_web_host} ${var.hindsight_api_host}"
      echo ""
      echo "Access via:"
      echo "  https://authelia.${var.domain}:${var.https_node_port}     (login portal)"
      echo "  https://clock.${var.domain}:${var.https_node_port}        (protected by Authelia)"
      echo "  https://registry.${var.domain}:${var.https_node_port}"
      echo "  https://sonos-mcp.${var.domain}:${var.https_node_port}    (MCP SSE endpoint)"
      echo "  https://mqtt-mcp.${var.domain}:${var.https_node_port}/mcp (Clock MCP Streamable HTTP endpoint)"
      echo "  https://${var.hindsight_web_host}:${var.https_node_port}  (Hindsight Control Plane UI)"
      echo "  https://${var.hindsight_api_host}:${var.https_node_port}  (Hindsight API)"
%{for host in var.sonos_mcp_extra_hosts~}
      echo "  https://${host}:${var.https_node_port}/mcp (Sonos MCP via extra host)"
%{endfor~}
%{for host in var.mqtt_mcp_extra_hosts~}
      echo "  https://${host}:${var.https_node_port}/mcp (Clock MCP via extra host)"
%{endfor~}
      echo ""
      echo "Export CA cert to trust it:"
      echo "  kubectl get secret homelab-ca-tls -n cert-manager -o jsonpath='{.data.tls\\.crt}' | base64 -d > homelab-ca.crt"
    EOT
  }

  depends_on = [helm_release.ingress_nginx]
}
