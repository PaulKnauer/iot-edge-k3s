# Home k3s (Raspberry Pi 4) + Mosquitto via Terragrunt

## Prereqs
- Terragrunt + Terraform installed
- SSH key created: ~/.ssh/k3s-edge-iot
- 4x Pis reachable via SSH (user: ubuntu)
- Hostnames: rpi4-1.local ... rpi4-4.local

## Apply
make apply-k3s
make apply-mqtt

## Verify
- kubeconfig written to: infra/.kube/home-k3s.yaml
- kubectl --kubeconfig infra/.kube/home-k3s.yaml get nodes -o wide
- Mosquitto NodePort default: 31883
  - broker: <any-node-ip>:31883

## Destroy
make destroy-mqtt
make destroy-k3s
