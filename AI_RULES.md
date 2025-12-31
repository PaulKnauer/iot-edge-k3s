# AI / Codex Guardrails (must follow)

- Do NOT hardcode secrets (tokens/passwords) in git.
- Keep Terraform idempotent: no "always run" scripts unless unavoidable.
- Any remote scripts must be safe to re-run.
- All node inventory must live in: infra/live/home/k3s/terragrunt.hcl
- Mosquitto must depend on k3s output kubeconfig path.
- Run:
  - make fmt
  - make plan-k3s / make plan-mqtt
before merging to main.
