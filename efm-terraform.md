# Enterprise Field Manual - Terraform Execution
**Document State:** [DEPLOYMENT COMPLETE & VERIFIED]

## Phase 0: Pre-Project Target Asset & Hardening
**Execution File:** `00-prerequisites.tf`
**Status:** Provisioned and Verified

### Architectural Objective
To mathematically prove the zero-trust capabilities of the AI and Cloud Pipeline Hardening Framework (ACPHF), a pristine, legacy-free target asset must first be established. This baseline ensures that subsequent data-plane audits are isolated, accurate, and completely free of legacy credential interference.

### Established Configurations & Target Hardening
* **Target Asset:** Azure Key Vault (`kv-efm-target-lab-01`).
* **Target Infrastructure Hardening (Phase 4.1):** Azure Key Vaults default to a legacy access model that actively overrides Entra ID role assignments. To prevent the "Silent 403" data-plane trap, the vault was strictly provisioned with `enable_rbac_authorization = true`, destroying the legacy baseline and shifting all control to Entra ID native RBAC.
* **Validation Payload:** A test secret (`efm-test-secret`) containing the explicit string: `confirm EFM Terraform configurations`.

---

## Execution Narrative: ACPHF Phases 1 & 2
**Execution Framework:** Intelligent Architecture Enterprise Field Manual (EFM)
**Tooling:** Terraform (`01-foundation.tf`)
**Status:** Deployed and Verified

### Engineering & Governance Rationale
To strictly adhere to the mandate for an auditable, zero-trust machine identity, we utilized Terraform to immutably execute the first two phases of the ACPHF specification. This execution programmatically extracts the deterministic routing coordinates required to populate the Identity Architecture Ledger (IAL).

* **Phase 1 (Core Cloud Boundary & Metadata Alignment):** We leveraged Terraform data sources to lock the deployment to the precise Entra ID tenant and Azure subscription boundaries. The resulting Tenant ID and Subscription ID were extracted as outputs to fulfill IAL Section 1.1 requirements.
* **Phase 2 (Non-Human Identity Provisioning):** We provisioned a strict single-tenant, headless Application Blueprint (`AzureADMyOrg` with zero redirect URIs) to eliminate legacy interactive vulnerabilities. The resulting Application (Client) ID and local Service Principal Object ID were explicitly outputted by the state engine to fulfill IAL Section 2.1.

---

## Execution Narrative: ACPHF Phase 3 & 3.5
**Execution Framework:** Intelligent Architecture Enterprise Field Manual (EFM)
**Tooling:** Terraform (`02-federation.tf`)
**Status:** Deployed, Tested, and Locked

### Engineering & Governance Rationale
To satisfy Phase 3 (Passwordless Cryptographic Federation), we eliminated the reliance on legacy static client secrets, engineering an ephemeral OpenID Connect (OIDC) trust directly between the Entra ID headless application and the external GitHub Actions runner.

* **Cryptographic Federation:** We provisioned the `azuread_application_federated_identity_credential` resource to bind the identity to the GitHub token issuer.
* **Cryptographic Handshake Verification (Phase 3.5):** External CI/CD runners dynamically inject unique, immutable repository and organization IDs into the token's Subject Claim. We mandated an intentional initial pipeline failure to deliberately trigger an Entra ID authentication block, transforming a blind guess into a precision telemetry trap.
* **Subject Claim Guard Enforcement:** We extracted the precise broadcast string from the failed telemetry and injected it into the control plane. This mathematically guarantees that Entra ID will only issue access tokens to this exact repository and branch, instantly dropping all unauthorized requests.

---

## Execution Narrative: ACPHF Phase 4 & The RBAC Deadlock
**Execution Framework:** Intelligent Architecture Enterprise Field Manual (EFM)
**Tooling:** Terraform (`03-rbac.tf`)
**Status:** Deployed, Patched, and Verified

### Engineering & Governance Rationale
To complete the ACPHF implementation, we established a mathematically sound authorization boundary using `azurerm_role_assignment` to grant the `Key Vault Secrets User` role to the headless Service Principal, scoped explicitly to `kv-efm-target-lab-01`. 

### Deployment Reality: The RBAC Deadlock
Transitioning Key Vault control exclusively to the Terraform state engine introduced a fatal race condition. When Terraform assumes control of the RBAC model (`enable_rbac_authorization = true`), it simultaneously destroys legacy access policies. Attempting to read or write a secret in the same run triggers an immediate 403 Forbidden error, locking the engine out of its own state configuration.

* **Engineering Control (Targeted Execution Protocol):** The deployment was halted and refactored into a surgical two-step execution.
* **Step 1:** Executed `terraform apply -target="azurerm_role_assignment.cli_secrets_officer"` to surgically grant the executing CLI administrator identity the required authorization.
* **Step 2:** Enforced a mandatory 60-second propagation window before running the standard `terraform apply` to build the remaining data-plane objects, successfully bypassing the deadlock.

---

## Execution Narrative: Continuous Governance & Telemetry
**Execution Framework:** Intelligent Architecture Enterprise Field Manual (EFM)
**Tooling:** Terraform (`04-telemetry.tf`)
**Status:** Deployed and Audited

### Deployment Reality: The Ghost Pipe
Relying on Azure's visual interface for post-deployment auditing introduced critical visibility gaps. The Azure portal often hides backend diagnostic settings, gaslighting engineers into assuming a workspace is malfunctioning when the telemetry pipe simply hasn't been instantiated. 

* **Engineering Control (Immutable Ledger Routing):** The telemetry pipe was formally codified as a mandatory, immutable resource block (`azurerm_monitor_diagnostic_setting`). The Key Vault (`target_resource_id`) and the Log Analytics Workspace (`log_analytics_workspace_id`) were strictly tethered in the code prior to secret generation, mathematically guaranteeing the flow of audit data.

---

## Execution Narrative: Final Audit & Circuit Verification
**Status:** ZERO-TRUST CIRCUIT VERIFIED

### Deployment Reality: The UI Trap
Executing the final KQL verification exposed a silent UI update in the Azure Portal. The Log Analytics interface defaulted to a restrictive "Simple Mode" visual builder, entirely hiding the raw KQL code editor and preventing the execution of strict schema projections.

* **Engineering Control (UI Bypass Protocol):** Engineers manually bypassed the "Queries" modal trap, toggled to "KQL mode," and executed a raw `AzureDiagnostics` pull to allow the dynamic schema to populate without crashing.

### Final Cryptographic Proof
The Log Analytics ledger successfully captured the complete execution state:
1. **The Deadlock Captured:** The ledger logged the initial `ResultDescription: "Caller is not authorized to perform action..."`, proving the circuit successfully detected the 403 access block.
2. **The Execution Verified:** A subsequent `SecretGet` operation logged a `Success` (HTTP 200).
3. **The Actor Identified:** The telemetry payload explicitly identified `admin@lab20250106.onmicrosoft.com` utilizing the `HashiCorp Terraform/1.5.6` client, proving the operation was securely executed by the declarative state engine and not a rogue interactive script.