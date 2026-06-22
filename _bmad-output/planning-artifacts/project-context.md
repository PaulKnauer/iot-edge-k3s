---
project_name: 'iot-edge-k3s'
user_name: 'Paul'
date: '2026-06-22'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality_rules', 'workflow_rules', 'critical_rules']
status: 'complete'
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when working in this repo. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- **Cluster:** k3s v1.29.9+k3s1 (pinned, Traefik disabled)
- **IaC:** Terraform + Terragrunt — modules in `infra/modules/<component>/`, live config in `infra/live/home/<component>/`
- **Workload deployment:** Helm charts via Terraform modules
- **Orchestration:** Make targets (`plan-*`, `apply-*`, `destroy-*`)
- **Persistent storage:** Longhorn for stateful workloads
- **SSH:** Key-based only (`~/.ssh/k3s-edge-iot`), never hardcoded
- **Secrets:** Passed via `TF_VAR_*` env vars, never committed to git
- **Nodes:** 6× Raspberry Pi 4 (3 HA control plane + 3 workers)

## Critical Implementation Rules

### Language-Specific Rules (HCL / Shell)

- All Terraform modules go in `infra/modules/<component>/`; live config in `infra/live/home/<component>/` with a `terragrunt.hcl`
- **Always** run `make fmt` before any merge (`terragrunt hclfmt` + `terraform fmt -recursive`)
- Every `terragrunt apply` must be idempotent — re-running produces no changes
- No hardcoded values in `.tf` or `.hcl` files — use `variables.tf` + Terragrunt inputs or `TF_VAR_*`
- Remote scripts (provisioners) must check if already installed and exit cleanly if so
- Always declare `outputs.tf` for cross-module references

### Framework-Specific Rules (k3s / Terragrunt / Helm)

- k3s v1.29.9+k3s1 is pinned — never auto-upgrade
- Traefik disabled — ingress managed externally
- Node inventory **only** in `infra/live/home/k3s/terragrunt.hcl`
- Never manually join/reset k3s nodes — always use Terragrunt
- Dependency chain: k3s → Longhorn → cert-manager → workloads → ingress
- All workloads deployed via Helm (`helm_release` resource) with Longhorn PVCs

### Testing Rules

- **`terraform plan` is the test** — always run `make plan-<component>` before applying
- **Idempotency check** — apply twice; second run must produce zero changes
- **`make fmt`** before every merge
- No CI/CD pipeline — validation is manual from workstation

### Code Quality & Style Rules

- `make fmt` before every merge (`terragrunt hclfmt` + `terraform fmt -recursive`)
- **Zero secrets in git** — use `TF_VAR_*` env vars only
- Naming: components lowercase with hyphens; Terraform resources follow standard HCL conventions
- Document *why* not *what* in comments
- Every module must define both `variables.tf` and `outputs.tf`

### Development Workflow Rules

- Feature branches off `main` with Conventional Commits
- All `apply` runs from MacBook workstation over SSH
- Manual PR review before any merge
- Verify PVC/persistence safety before destructive operations on stateful workloads

### Critical Don't-Miss Rules

- ❌ **Never hardcode k3s tokens, MQTT passwords, or SSH keys in `.tf` / `.hcl`** — use `TF_VAR_*` only
- ❌ **No `null_resource` without meaningful `triggers`** — prevents unnecessary re-provisioning
- ❌ **No unconditional reboot/reinstall in remote-exec** — every provisioner must be idempotent
- ❌ **Node inventory in one place only:** `infra/live/home/k3s/terragrunt.hcl`
- ❌ **Never manually run k3s join commands over SSH** — always through Terragrunt
- ⚠️ Longhorn PVCs survive Helm `Recreate` upgrades — but **always verify** `storage_class = "longhorn"` before touching stateful pods
- ⚠️ cert-manager must deploy **before** workloads that need TLS certs

---

## Usage Guidelines

**For AI Agents:**
- Read this file before implementing any code in this repo
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Update this file if new patterns emerge

**For Humans:**
- Keep this file lean and focused on what agents need
- Update when technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

Last Updated: 2026-06-22
