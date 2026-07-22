# 3. Private endpoints + private DNS zones for every PaaS dependency

- Status: accepted
- Date: 2022

## Context

The cluster depends on managed services — Azure Container Registry, Key Vault,
Blob storage, and PostgreSQL. Each of these has a public endpoint by default.
In an isolated design, workloads should reach them **without traffic leaving the
private network**, and name resolution has to point at the private addresses.

## Decision

Give each dependency a **private endpoint** in the spoke `VmSubnet`, and create a
matching **private DNS zone** (`privatelink.azurecr.io`, `…vaultcore.azure.net`,
`…blob.core.windows.net`, `…postgres.database.azure.com`) **linked to both the
hub and spoke VNets**. A `private_endpoint` module and a `private_dns_zone`
module are instantiated once per service so the pattern is uniform.

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Service endpoints** | Simpler and free, but they keep the resource's **public** endpoint (just restricting which subnets can use it) rather than giving it a private IP — weaker isolation and no cross-VNet/on-prem story. |
| **Public endpoints + firewall/IP allow-lists** | Traffic still traverses public endpoints; more moving firewall rules and a bigger surface. |
| **One shared DNS zone, linked to one VNet** | Would break resolution from the other VNet; endpoints must resolve from both hub and spoke, so each zone links to both. |

## Consequences

- **Good:** ACR pulls, Key Vault reads, blob access, and DB traffic all resolve to
  private IPs and stay on the VNet. Combined with ADR-0002, there's effectively no
  public data path in or out.
- **Trade-off:** **more resources and DNS complexity** — every service is now an
  endpoint + a zone + two VNet links + a zone group. Misconfigured DNS links are
  the classic failure mode (resolution silently returns public IPs).
- **Trade-off:** private endpoints have their own hourly + per-GB cost.

## Revisit if

The service count grows — centralize the private DNS zones in the hub (or Azure
Private DNS Resolver) instead of per-deployment, to cut duplication.
