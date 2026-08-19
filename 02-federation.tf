# ---------------------------------------------------------
# PHASE 3: PASSWORDLESS CRYPTOGRAPHIC FEDERATION
# ---------------------------------------------------------

# 1. Establish OIDC Trust for GitHub Actions
resource "azuread_application_federated_identity_credential" "github_actions_oidc" {
  application_id = azuread_application.acphf_agent.id
  display_name   = "github-actions-oidc-trust"
  description    = "OIDC trust for GitHub Actions EFM Pipeline"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  
  # THE FIX: Immutable ID-bound subject claim matching the exact GitHub broadcast
  subject        = "repo:Compcode1@171821203/efm-terraform@1337794142:ref:refs/heads/main"
}