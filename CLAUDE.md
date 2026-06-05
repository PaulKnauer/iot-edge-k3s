# CLAUDE.md — Home k3s (Raspberry Pi) Project

This file is loaded as persistent context by AI agents. It supplements AGENTS.md (the primary operating contract for this repo).

## Quick Start

```bash
make plan-k3s          # terraform plan for k3s cluster
make apply-k3s         # apply k3s cluster provisioning
make plan-mqtt         # plan Mosquitto deployment
make apply-mqtt        # deploy Mosquitto
make fmt               # terragrunt hclfmt + terraform fmt -recursive
make plan-sonos-mcp    # plan Sonos MCP server
```

## Key Architecture

- **Terraform + Terragrunt** — `infra/live/home/<component>/` for live config, `infra/modules/<component>/` for modules
- **6-node Pi cluster**: 3 HA control plane (rpi4-1..3) + 3 workers (rpi4-4..6)
- **k3s v1.29.9+k3s1** pinned, Traefik disabled
- **Secrets**: passed via `TF_VAR_*` env vars, never committed
- **SSH**: key-based only (`~/.ssh/k3s-edge-iot`)

## Rules

1. ALL node inventory lives only in `infra/live/home/k3s/terragrunt.hcl`
2. ALL Terraform applies MUST be idempotent — re-running produces no changes
3. Never hardcode IPs, hostnames, or SSH keys outside their single source of truth
4. Never manually join/reset k3s nodes over SSH — always use Terragrunt
5. Run `make fmt` before any merge

## Workloads

| Component | NodePort | Module path |
|---|---|---|
| Mosquitto (MQTT) | 31883 | `infra/modules/mosquitto/` |
| Docker Registry | 32000 | `infra/modules/registry/` |
| Clock Server | 31881 | `infra/modules/clock-server/` |
| Authelia | 31917 | `infra/modules/authelia/` |
| Sonos MCP | 31800 | `infra/modules/sonos-mcp/` |
| cert-manager | — | `infra/modules/cert-manager/` |
| Longhorn | — | `infra/modules/longhorn/` |
| Node-RED | — | `infra/modules/nodered/` |
| n8n | — | `infra/modules/n8n/` |
| Qdrant | — | `infra/modules/qdrant/` |
