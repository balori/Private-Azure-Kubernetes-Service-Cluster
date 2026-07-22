# 1. Private API server, accessed via jumpbox + Azure Bastion over peering

- Status: accepted
- Date: 2022

## Context

The client requirement is an isolated, hardened cluster. A default AKS cluster
exposes its Kubernetes API server on a public IP. For an insurance workload that
is unacceptable — the control plane must not be reachable from the internet. But
a private API server still has to be *operable* by engineers and CI.

## Decision

Enable a **private cluster** (`private_cluster_enabled = true`), so the API
server is reachable only through a Private Link endpoint on the cluster VNet.
Operate it through a **jumpbox VM** placed in the spoke `VmSubnet`, reached via
**Azure Bastion** in the hub `AzureBastionSubnet` over hub↔spoke peering. Nodes
run with no public IP (`enable_node_public_ip = false`).

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Public cluster + API authorized IP ranges** | Simplest to operate, but the API server still has a public endpoint — only IP-filtered. Doesn't meet "not exposed via a public IP." |
| **VPN / ExpressRoute to the VNet** | Correct for real on-prem connectivity, but heavy to stand up for this scope and adds gateway cost/ops. Kept as the on-prem story, not the day-one access path. |
| **`az aks command invoke`** | No infra needed, but it's a constrained, run-a-command escape hatch, not a real operational workflow. |
| **Private endpoint from a separate VNet** | Viable, but another VNet + endpoint to manage; the jumpbox-in-spoke path is simpler here. |

## Consequences

- **Good:** the control plane has no public surface; all admin traffic flows
  Bastion → jumpbox → private API endpoint, entirely on Azure's backbone.
- **Trade-off:** you can't `kubectl` from a laptop directly — you go through the
  jumpbox. Application deploys from CI need a **self-hosted agent inside the
  network** (documented in the README), because Microsoft-hosted agents can't
  reach the private endpoint.
- **Trade-off:** the jumpbox + Bastion are always-on cost and another host to
  patch.

## Revisit if

Real on-prem connectivity arrives — fold in VPN/ExpressRoute via the hub and the
jumpbox becomes a break-glass path rather than the primary one.
