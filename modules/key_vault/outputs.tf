output "name" {
  value       = azurerm_key_vault.key_vault.name
  description = "Specifies the name of the key vault."
}

output "id" {
  value       = azurerm_key_vault.key_vault.id
  description = "Specifies the resource id of the key vault."
}

output "access_id" {
  value       = azurerm_key_vault_access_policy.access_policy.id
  description = "Specifies the resource id of the key vault access policy."
}