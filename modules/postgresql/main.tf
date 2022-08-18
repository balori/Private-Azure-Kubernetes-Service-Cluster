resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "postgresql_pw" {
  name         = "postgresqlpw"
  value        = random_password.password.result
  key_vault_id = var.key_vault_id

  depends_on = [
    var.access_id
  ]
}
resource "random_string" "postgresql_suffix" {
  length  = 5
  special = false
  lower   = true
  upper   = false
  numeric  = false
}
#Create postgre server
resource "azurerm_postgresql_server" "postgres_svr" {
  name                         = "${var.env}-postgresql-${random_string.postgresql_suffix.result}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku_name                     = "GP_Gen5_2"
  administrator_login          = var.adminname
  administrator_login_password = random_password.password.result

  version                 = "9.5"
  ssl_enforcement_enabled = true
}

resource "azurerm_postgresql_database" "poc_postgres_db" {
  name                = "${var.env}-postgresql-db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres_svr.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "pgsql-fw-rule" {
  count               = length(var.firewall_rules)
  name                = "${var.env}-pgsql-fw-rule"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgres_svr.name
  start_ip_address    = "1.2.3.4"
  end_ip_address      = "5.6.7.8"
}

resource "azurerm_postgresql_virtual_network_rule" "postgresql_vnet_rule" {
  name                                 = "${var.env}-postgresql-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = azurerm_postgresql_server.postgres_svr.name
  subnet_id                            = var.postgres_subnet_id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_postgresql_server.postgres_svr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "PostgreSQLLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}