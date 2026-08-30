# Authelia Rollout via `iot-edge-k3s`

**Goal:** Restore/apply the repo-managed Authelia deployment and expose it through the existing shared ingress on the homelab cluster.

## Current context
- Repo already contains `infra/modules/authelia/` and live config at `infra/live/home/authelia/terragrunt.hcl`.
- Live cluster currently has no `authelia` namespace/resources.
- Terraform state for `infra/live/home/authelia` already exists and contains the previously-used Authelia secret material and admin hash.
- Shared ingress already depends on `../authelia`, but current live ingresses do not include `authelia.home.lab`, so ingress re-apply is likely required after Authelia is restored.
- Local `~/.kube/config` is stale; use a live kubeconfig fetched from `rpi4-1` for verification.

## Approach
1. Recover the existing Authelia secrets from Terraform state into a temporary env file so no new credentials are invented.
2. Run repo-native `terragrunt plan/apply -auto-approve` in `infra/live/home/authelia`.
3. Re-apply the shared ingress null-resource so the Authelia ingress object is rendered now that the namespace/service exist.
4. Verify namespace, pods, service, PVC, ingress, rollout, and an HTTPS host-header request.

## Files involved
- `infra/live/home/authelia/terragrunt.hcl`
- `infra/modules/authelia/main.tf`
- `infra/live/home/ingress/terragrunt.hcl`
- `infra/modules/ingress/main.tf`

## Validation
- `terragrunt plan -detailed-exitcode` in `infra/live/home/authelia`
- `terragrunt apply -auto-approve` in `infra/live/home/authelia`
- `terragrunt run -- taint 'null_resource.cert_and_ingress'` then `terragrunt apply -auto-approve` in `infra/live/home/ingress`
- `kubectl get all,pvc,ingress -n authelia`
- `kubectl rollout status deployment/authelia -n authelia`
- `curl -k -I --resolve authelia.home.lab:30443:192.168.2.201 https://authelia.home.lab:30443/`

## Risks / watchouts
- Terragrunt will fail unless all Authelia secrets are supplied.
- OIDC is enabled in the live config, so the OIDC HMAC key, JWKS private key, and client secret hash must also be restored.
- Ingress is managed by a shared `null_resource`; if it was previously applied before the namespace existed, Authelia ingress may remain absent until explicitly re-run.
- Keep the recovered secrets in a temp file with restrictive permissions and remove it after apply.
