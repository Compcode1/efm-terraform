# ---------------------------------------------------------
# PHASE 1: CORE CLOUD BOUNDARY & METADATA ALIGNMENT
# ---------------------------------------------------------

# Explicitly lock the Entra ID (Identity Root) execution context
data "azuread_client_config" "current" {}

# (Note: Azure Subscription context data source is inherited from 00-prerequisites.tf)

# ---------------------------------------------------------
# PHASE 2: NON-HUMAN IDENTITY PROVISIONING
# ---------------------------------------------------------

# 1. Register Headless Application Blueprint
resource "azuread_application" "acphf_agent" {
  display_name     = "acphf-agent-01"
  sign_in_audience = "AzureADMyOrg" # Enforces Single-Tenant boundary

  # Attack Surface Minimization: 
  # Zero reply-uris configured to inherently deny browser callbacks.
}

# 2. Instantiate Local Security Context
resource "azuread_service_principal" "acphf_agent_sp" {
  client_id    = azuread_application.acphf_agent.client_id
  use_existing = false
}

# ---------------------------------------------------------
# IDENTITY ARCHITECTURE LEDGER (IAL) DATA EXTRACTION
# ---------------------------------------------------------

output "ial_tenant_id" {
  value       = data.azuread_client_config.current.tenant_id
  description = "IAL Section 1.1: Tenant ID (Identity Root)"
}

output "ial_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "IAL Section 1.1: Subscription ID (Asset Root)"
}

output "ial_application_client_id" {
  value       = azuread_application.acphf_agent.client_id
  description = "IAL Section 2.1: Application (Client) ID"
}

output "ial_service_principal_object_id" {
  value       = azuread_service_principal.acphf_agent_sp.object_id
  description = "Local Service Principal Object ID (Required for Phase 4 RBAC)"
}