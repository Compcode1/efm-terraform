# ---------------------------------------------------------
# PHASE 4: DATA-PLANE ACCESS (RBAC)
# ---------------------------------------------------------

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.efm_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.acphf_agent_sp.object_id
  
  # This flag prevents a race condition where Azure RBAC tries to assign 
  # the role before the new Entra ID Service Principal has fully propagated 
  # across Microsoft's global backend.
  skip_service_principal_aad_check = true
}