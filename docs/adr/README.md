# Architecture Decision Records

The significant design decisions behind this private-AKS platform, each with the
alternatives weighed and the trade-offs accepted. Lightweight
[MADR](https://adr.github.io/madr/) format.

| # | Decision | Status |
|---|----------|--------|
| [0001](0001-private-cluster-access-model.md) | Private API server, accessed via jumpbox + Bastion over peering | accepted |
| [0002](0002-hub-spoke-firewall-egress.md) | Hub-and-spoke topology with Azure Firewall egress (userDefinedRouting) | accepted |
| [0003](0003-private-endpoints-and-dns.md) | Private endpoints + private DNS zones for every PaaS dependency | accepted |
| [0004](0004-appgw-ingress-controller.md) | Application Gateway Ingress Controller (AGIC) for L7 + WAF | accepted |
| [0005](0005-aad-rbac-managed-identities.md) | AAD-integrated RBAC + user-assigned managed identities | accepted |
