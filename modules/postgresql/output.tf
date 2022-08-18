output "name" {
  description = "Specifies the name of the postgresql"
  value       = azurerm_postgresql_server.postgres_svr.name
}

output "id" {
  description = "Specifies the resource id of the postgresql"
  value       = azurerm_postgresql_server.postgres_svr.id
}