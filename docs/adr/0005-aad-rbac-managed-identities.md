# 5. AAD-integrated RBAC and user-assigned managed identities (no in-cluster secrets)

- Status: accepted
- Date: 2022

## Context

The cluster and its add-ons need Azure permissions (pull from ACR, program the
gateway, manage networking), and human access to the cluster needs to be
governed. The failure mode to avoid is long-lived credentials — service-principal
secrets or an admin kubeconfig floating around.

## Decision

- **User-assigned managed identities** for the AKS control plane and the
  Application Gateway — no client secrets.
- **AAD-integrated Kubernetes RBAC** (`azure_active_directory_role_based_access_control`
  with `azure_rbac_enabled`), so cluster access is granted to Azure AD groups
  (`admin_group_object_ids`), not local accounts.
- **Scoped role assignments** for exactly what each identity needs: `AcrPull` for
  the kubelet identity, `Network Contributor` + `Managed Identity Operator` for the
  cluster identity, `Contributor`/`Reader` for the gateway identity.
- SSH keys are **generated in Terraform** (`tls_private_key`) and stored in **Key
  Vault**, not committed or printed.

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Service principal + client secret** | A long-lived secret to store, rotate, and leak. Managed identities remove the secret entirely. |
| **Local Kubernetes accounts / admin kubeconfig** | No central governance, no AAD group mapping, and the admin kubeconfig is a standing bearer credential. |
| **Broad role assignments (e.g. Contributor on the subscription)** | Easy but over-privileged; each identity is instead scoped to the narrowest role that works. |

## Consequences

- **Good:** no static identity secrets in the cluster; access is governed by AAD
  group membership; each component holds least privilege.
- **Trade-off:** assigning these roles requires the deploying principal to have
  **Owner** (not just Contributor) on the scope — the README calls this out for
  both the local and Azure DevOps paths.
- **Trade-off:** AAD group object IDs must be provisioned and supplied as input;
  the design assumes an AAD tenant with the right groups.

## Revisit if

Workload-level Azure access is needed — adopt **Workload Identity** (federated
credentials) so pods get scoped identities without node-level managed-identity
sharing.
