# 4. Application Gateway Ingress Controller (AGIC) for L7 ingress + WAF

- Status: accepted
- Date: 2022

## Context

Workloads need load-balanced, layer-7 ingress with room for SSL termination and a
web application firewall — appropriate for an insurance-facing service. The
ingress entry point should sit at the network edge, not be a pod the cluster has
to keep healthy itself.

## Decision

Use **Azure Application Gateway** (`Standard_v2`, capacity 2) in its own
`appgw_subnet`, wired to the cluster through the AKS **`ingress_application_gateway`
add-on (AGIC)**. AGIC watches Kubernetes ingress resources and programs the
gateway. The gateway gets a user-assigned identity with scoped role assignments
(Contributor on the gateway, Reader on the RG).

## Alternatives considered

| Option | Why not |
|--------|---------|
| **In-cluster NGINX ingress + Azure LoadBalancer** | Portable and cheap, but the ingress tier then runs as pods you scale/patch, and a public LB service would poke a hole in the isolation model. AGIC keeps ingress at the managed edge. |
| **Front Door** | Global L7 + WAF, but it's a global/CDN-oriented service; for a single-region private workload the regional Application Gateway is the right fit. |
| **Standard_v2 without WAF vs WAF_v2** | Standard_v2 chosen here; WAF_v2 is the drop-in upgrade when the WAF ruleset is needed — a SKU change, not a redesign. |

## Consequences

- **Good:** managed L7 routing and SSL offload at the edge; ingress definitions
  stay native Kubernetes objects (AGIC translates them); a clear path to WAF by
  moving to `WAF_v2`.
- **Trade-off:** Application Gateway is **always-on cost** and the AGIC add-on
  couples the cluster's lifecycle to the gateway (identity + role assignments must
  exist for it to program routes).
- **Trade-off:** AGIC has feature lag vs. NGINX for some advanced ingress
  annotations.

## Revisit if

Advanced/custom ingress behavior is needed that AGIC doesn't support, or a global
multi-region front door becomes a requirement.
