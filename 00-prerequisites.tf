terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0" 
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Extract local CLI identity 
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "efm_target" {
  name     = "rg-efm-target-lab"
  location = "westus"
}

resource "azurerm_key_vault" "efm_vault" {
  name                       = "kv-efm-target-lab-01" 
  location                   = azurerm_resource_group.efm_target.location
  resource_group_name        = azurerm_resource_group.efm_target.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  
  purge_protection_enabled   = false
  enable_rbac_authorization  = true 
}

# --- THE LOCKOUT FIX ---
# Grant the executing user data-plane access under the new RBAC model
resource "azurerm_role_assignment" "cli_secrets_officer" {
  scope                = azurerm_key_vault.efm_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "efm_test_secret" {
  name         = "efm-test-secret"
  value        = "confirm EFM Terraform configurations"
  key_vault_id = azurerm_key_vault.efm_vault.id
  
  depends_on = [
    azurerm_key_vault.efm_vault,
    azurerm_role_assignment.cli_secrets_officer
  ]
}