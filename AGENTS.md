# AGENTS.md
## AI Agent Operating Contract – Home k3s (Raspberry Pi) Project

This document defines **strict operating rules** for any AI agent (e.g. Codex)
working in this repository.  
The goal is **safe, repeatable Infrastructure-as-Code** for a Raspberry Pi k3s cluster.

---

## 1. Project Intent (Read First)

This repository manages:
- A **k3s Kubernetes cluster** on Raspberry Pi 4 (Ubuntu Server)
- Provisioned via **Terraform + Terragrunt**
- Accessed over **SSH**
- Application workloads deployed via **Helm**
- Primary workload: **Eclipse Mosquitto (MQTT broker)**

This is a **homelab**, but must follow **production-grade IaC discipline**:
idempotent, reviewable, reversible.

---

## 2. Source of Truth

### Single sources of truth (DO NOT DUPLICATE)

| Concern | Location |
|------|--------|
| Node inventory | `infra/live/home/k3s/terragrunt.hcl` |
| SSH settings | `infra/live/home/k3s/terragrunt.hcl` |
| Cluster endpoint | `infra/live/home/k3s/terragrunt.hcl` |
| k3s version | `infra/live/home/k3s/terragrunt.hcl` |
| Kubeconfig path | `infra/terragrunt.hcl` |
| Helm deployments | `infra/modules/*` |

❌ **Never hardcode hosts, IPs, usernames, or keys anywhere else.**

---

## 3. Security Rules (NON-NEGOTIABLE)

### Secrets
- **NEVER** commit secrets
- **NEVER** hardcode tokens, passwords, or credentials
- Secrets must be passed via:
  - environment variables (`TF_VAR_*`), or
  - external secret tooling (future SOPS support)

Examples of forbidden behavior:
- embedding `k3s_token` in `.tf` or `.hcl`
- embedding MQTT passwords in Helm values files

### SSH
- SSH authentication uses **key-based auth only**
- Private key paths must be variables
- Never assume `~/.ssh/id_rsa`

---

## 4. Terraform / Terragrunt Rules

### Idempotency (CRITICAL)
All Terraform applies **must be idempotent**:
- A second `terragrunt apply` must result in **no changes**
- Remote scripts must:
  - check if software is already installed
  - exit cleanly if so

Forbidden patterns:
- `null_resource` without meaningful `triggers`
- scripts that reinstall k3s on every apply
- scripts that reboot nodes unconditionally

### Ordering
- k3s **server init** must complete before:
  - server joins
  - agent joins
- Use `depends_on` explicitly where ordering matters

### Formatting
Before any merge:
```bash
terragrunt hclfmt
terraform fmt -recursive
