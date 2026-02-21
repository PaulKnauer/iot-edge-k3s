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

## Verify
- kubeconfig written to: infra/.kube/home-k3s.yaml
- kubectl --kubeconfig infra/.kube/home-k3s.yaml get nodes -o wide
- Docker registry NodePort default: 32000
  - registry: `<any-node-ip>:32000`
- Mosquitto NodePort default: 31883
  - broker: <any-node-ip>:31883

## Push Images To Local Registry
- Optional (recommended): enable registry auth before apply
  - `export TF_VAR_htpasswd="$(htpasswd -nbB registryuser 'strong-password')"`
- Login:
  - `docker login <any-node-ip>:32000 -u registryuser -p 'strong-password'`
- Tag and push:
  - `docker tag alpine:3.20 <any-node-ip>:32000/alpine:3.20`
  - `docker push <any-node-ip>:32000/alpine:3.20`

## Destroy
make destroy-registry
make destroy-mqtt
make destroy-longhorn
make destroy-k3s
