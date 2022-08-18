variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the private dns zone"
  type        = string
}

variable "env" {
  description = "(Required) Specifies the environment name (prod/dev/qa)."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location where the AKS cluster will be deployed."
  type        = string
}

variable "adminname" {
  description = "(Required) Admin name of database."
  type        = string
  default     = "insurance_companyadmin"
}

variable "firewall_rules" {
  description = "The list of maps, describing firewall rules. Valid map items: name, start_ip, end_ip."
  type        = list(map(string))
  default     = []
}

variable "postgres_subnet_id" {
  description = "(Required) Specifies the subnet where postgress will be deployed."
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the private dns zone"
  default     = {}
}

variable "key_vault_id" {
  description = "(Required) Key Vault where Postgress password would be saved."
  type        = string
}

variable "access_id" {
  description = "(Required) Key Vault Access policies id."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 30
}