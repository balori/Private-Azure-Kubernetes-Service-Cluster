# 2. Hub-and-spoke topology with Azure Firewall egress (userDefinedRouting)

- Status: accepted
- Date: 2022

## Context

A hardened cluster must not have unrestricted outbound internet. By default AKS
egresses through a managed load balancer with an open path out. The client needs
egress that can be **inspected, filtered, and logged**, and a network layout that
can later connect to on-prem.

## Decision

Adopt a **hub-and-spoke** topology: a hub VNet holding shared edge services
(`AzureFirewallSubnet`, `AzureBastionSubnet`) peered with an AKS **spoke** VNet
(system/user node subnets, VM, AppGw, PostgreSQL subnets). Set the cluster's
`outbound_type = "userDefinedRouting"` and attach a **route table** that sends
`0.0.0.0/0` from the node subnets to the **Azure Firewall** private IP. Firewall
logs flow to Log Analytics.

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Default load-balancer outbound** | Zero-config, but no egress filtering or centralized logging — the opposite of the hardening requirement. |
| **NAT Gateway** | Solves SNAT port exhaustion cleanly and is cheaper, but it's plumbing, not a policy/inspection point — no FQDN/threat filtering. |
| **NSG rules only** | NSGs filter by IP/port, not FQDN, and aren't a natural place for centralized egress logging; AKS needs FQDN-based allow-listing. |
| **Flat single VNet** | Simpler, but no clean separation of shared edge services from workload, and no path to on-prem via a hub. |

## Consequences

- **Good:** every packet leaving the nodes is routed through the firewall —
  inspectable, filterable by FQDN/threat intel, and logged centrally. The hub is
  the future attach point for on-prem/ExpressRoute.
- **Trade-off:** Azure Firewall is a **non-trivial fixed cost** and a component to
  operate. It's also a hard dependency: the required AKS egress FQDNs/rules must
  be allow-listed or nodes fail to bootstrap (the README flags that firewall
  rules need tuning per workload).
- **Trade-off:** `userDefinedRouting` means AKS won't manage outbound for you —
  the route table is now yours to keep correct.

## Revisit if

Egress cost dominates and FQDN filtering isn't required — a NAT Gateway per spoke
is a cheaper SNAT-only alternative.
