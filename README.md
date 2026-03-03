# Home k3s (Raspberry Pi 4) + workloads via Terragrunt

## Prereqs
- Terragrunt + Terraform installed
- SSH key created: ~/.ssh/k3s-edge-iot
- 4x Pis reachable via SSH (user: ubuntu)
- Hostnames: rpi4-1.local ... rpi4-4.local

## Apply
make apply-k3s
make apply-longhorn
make apply-registry
make apply-mqtt
make apply-clock-server
make apply-cert-manager
make apply-ingress

## Verify
- kubeconfig written to: infra/.kube/home-k3s.yaml
- kubectl --kubeconfig infra/.kube/home-k3s.yaml get nodes -o wide
- Docker registry NodePort default: 32000
  - registry: `<any-node-ip>:32000`
- Mosquitto NodePort default: 31883
  - broker: <any-node-ip>:31883
- Clock server NodePort default: 31881
  - app: <any-node-ip>:31881

## HTTPS Ingress (cert-manager + nginx-ingress)
Add to `/etc/hosts` on each client:
```
192.168.2.201  clock.home.lab nodered.home.lab registry.home.lab
```
Access services at HTTPS NodePort 30443:
- https://clock.home.lab:30443
- https://nodered.home.lab:30443
- https://registry.home.lab:30443 (Docker registry via HTTPS)

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
make destroy-cert-manager
make destroy-clock-server
make destroy-registry
make destroy-mqtt
make destroy-longhorn
make destroy-k3s
