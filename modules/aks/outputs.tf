output "id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.id
  description = "Specifies the resource id of the AKS cluster."
}

output "aks_identity_principal_id" {
  value       = azurerm_user_assigned_identity.aks_identity.principal_id
  description = "Specifies the principal id of the managed identity of the AKS cluster."
}

output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
  description = "Specifies the object id of the kubelet identity of the AKS cluster."
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  description = "Contains the Kubernetes config to be used by kubectl and other compatible tools."
}

output "private_fqdn" {
  value       = azurerm_kubernetes_cluster.aks_cluster.private_fqdn
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster."
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  description = "Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}

output "appgw_id" {
  value       = azurerm_application_gateway.appgw.id
  description = "Specifies the principal id of the Application Gateway."
}

output "appgw_principal_id" {
  value       = azurerm_user_assigned_identity.AppGWIdentity.principal_id
  description = "Specifies the user assigned identity principal id to the Application Gateway."
}

