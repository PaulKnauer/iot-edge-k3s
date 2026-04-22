# Home k3s (Raspberry Pi 4) + workloads via Terragrunt

## Prereqs
- Terragrunt + Terraform installed
- SSH key created: ~/.ssh/k3s-edge-iot
- 6x Pis reachable via SSH (user: ubuntu)
- Hostnames: rpi4-1.local ... rpi4-6.local

## Apply
make apply-k3s
make apply-longhorn
make apply-registry
make apply-mqtt
make apply-clock-server
make apply-cert-manager
make apply-authelia
make apply-ingress

For Authelia, export secrets before `make apply-authelia`:
```
export TF_VAR_authelia_jwt_secret="$(openssl rand -base64 48)"
export TF_VAR_authelia_session_secret="$(openssl rand -base64 48)"
export TF_VAR_authelia_storage_key="$(openssl rand -base64 48)"
read -rsp "Authelia admin password: " AUTHELIA_ADMIN_PASSWORD; echo
export TF_VAR_authelia_admin_hash="$(docker run --rm authelia/authelia:4.38.9 authelia crypto hash generate argon2 --password "$AUTHELIA_ADMIN_PASSWORD" | awk '/Digest:/ {print $2}')"
unset AUTHELIA_ADMIN_PASSWORD
export TF_VAR_authelia_oidc_hmac_secret="$(openssl rand -base64 48)"
export TF_VAR_authelia_oidc_jwks_private_key="$(openssl genrsa 4096)"
read -rsp "Authelia OIDC test-client secret: " AUTHELIA_OIDC_CLIENT_SECRET; echo
export TF_VAR_authelia_oidc_client_secret_hash="$(docker run --rm authelia/authelia:4.38.9 authelia crypto hash generate pbkdf2 --variant sha512 --password "$AUTHELIA_OIDC_CLIENT_SECRET" | awk '/Digest:/ {print $2}')"
unset AUTHELIA_OIDC_CLIENT_SECRET
```

## Verify
- kubeconfig written to: infra/.kube/home-k3s.yaml
- kubectl --kubeconfig infra/.kube/home-k3s.yaml get nodes -o wide
- Docker registry NodePort default: 32000
  - registry: `<any-node-ip>:32000`
- Mosquitto NodePort default: 31883
  - broker: <any-node-ip>:31883
- Clock server NodePort default: 31881
  - app: <any-node-ip>:31881
- Authelia NodePort default: 31917
  - portal: <any-node-ip>:31917

## HTTPS Ingress (cert-manager + nginx-ingress)
Add to `/etc/hosts` on each client:
```
192.168.2.201  clock.home.lab nodered.home.lab registry.home.lab authelia.home.lab
```
Access services at HTTPS NodePort 30443:
- https://clock.home.lab:30443
- https://nodered.home.lab:30443
- https://registry.home.lab:30443 (Docker registry via HTTPS)
- https://authelia.home.lab:30443

Export the self-signed CA cert to trust it (removes browser warnings):
```
kubectl --kubeconfig infra/.kube/home-k3s.yaml \
  get secret homelab-ca-tls -n cert-manager \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > homelab-ca.crt
```
On macOS: `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain homelab-ca.crt`

For Docker to push/pull via HTTPS registry:
```
docker login registry.home.lab:30443
```

## Push Images To Local Registry
- Optional (recommended): enable registry auth before apply
  - `export TF_VAR_htpasswd="$(htpasswd -nbB registryuser 'strong-password')"`
- Login:
  - `docker login <any-node-ip>:32000 -u registryuser -p 'strong-password'`
- Tag and push:
  - `docker tag alpine:3.20 <any-node-ip>:32000/alpine:3.20`
  - `docker push <any-node-ip>:32000/alpine:3.20`

## Destroy
make destroy-ingress
make destroy-authelia
make destroy-cert-manager
make destroy-clock-server
make destroy-registry
make destroy-mqtt
make destroy-longhorn
make destroy-k3s
