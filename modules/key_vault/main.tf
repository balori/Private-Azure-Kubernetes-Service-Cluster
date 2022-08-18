data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                            = "${var.env}-kv-${var.random}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  timeouts {
    delete = "60m"
  }

  network_acls {
    bypass                     = var.bypass
    default_action             = var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "Create", "List", "Import", "Sign", "Recover",
  ]

  secret_permissions = [
    "Get", "Set", "List", "Recover", "Backup", "Delete", "Purge", "Restore",
  ]

  certificate_permissions = [
    "Get", "Create", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "SetIssuers", "Update", "Recover",
  ]
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
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