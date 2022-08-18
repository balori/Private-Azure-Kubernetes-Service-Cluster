# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraformstate"
    storage_account_name = "clrhprdterraformstate"
    container_name       = "terraformstate"
    key                  = "infrax.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # subscription_id = "xxxxxx"
  # client_id       = "xxxxxx"
  # client_secret   = "xxxxxx"
  # tenant_id       = "xxxxxx"
}
