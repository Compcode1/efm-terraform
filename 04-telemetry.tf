# ---------------------------------------------------------
# PHASE 4.5: TELEMETRY & AUDIT TRAPS (ARL PREPARATION)
# ---------------------------------------------------------

# 1. Provision the Log Analytics Workspace (The Audit Ledger)
resource "azurerm_log_analytics_workspace" "efm_audit" {
  name                = "law-efm-audit-01"
  location            = azurerm_resource_group.efm_target.location
  resource_group_name = azurerm_resource_group.efm_target.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Route Key Vault Data-Plane Logs to the Workspace
resource "azurerm_monitor_diagnostic_setting" "kv_audit_trap" {
  name                       = "kv-audit-routing"
  target_resource_id         = azurerm_key_vault.efm_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.efm_audit.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}