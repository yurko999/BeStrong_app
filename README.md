# BeStrong - Azure Infrastructure

**Project:** BeStrong backend platform
**Delivery method:** Terraform (modular), `azurerm` provider `~> 4.0`, remote state on Azure Blob

---

## 1. Purpose

The client asked for a managed, private, secure home for a Dockerised backend with a SQL database, file storage, secrets, image registry, and centralised monitoring - with no VMs to babysit and "passwordless" access between services. This document translates each request into concrete Azure resources and describes what was built.

---

## 2. Requirements → Azure resources 

| # | Client said | Azure resource(s) used | Why this resource |
|---|------------------------------|------------------------|-------------------|
| 1 | "Run our backend… no VMs… managed… just deploy code" | **Azure Container Apps** - `azurerm_container_app` + `azurerm_container_app_environment` (workload-profiles, Consumption) | Serverless managed container platform. No OS/VM patching, scales on demand, you deploy a container image and it runs. The right fit for "managed, no VMs." |
| 2 | "Introduce itself to other Azure services without passwords" | **User-Assigned Managed Identity** - `azurerm_user_assigned_identity` + **RBAC role assignments** (`AcrPull`, `Key Vault Secrets User`, Entra SQL admin) | An Entra-backed identity authenticates with tokens, not credentials. One shared identity is reused across ACR, Key Vault and SQL - no secrets in code or config. |
| 3 | "Sit inside our private network, not exposed more than necessary" | **VNet + delegated subnet + internal environment** - `internal_load_balancer_enabled = true` | The Container Apps environment is created with **no public IP**; the app is reachable only from inside the VNet via an internal load balancer. |
| 4 | "Know why things crash - logs, charts, errors in one place, connected to the code" | **Log Analytics Workspace + Application Insights** - `azurerm_log_analytics_workspace` + `azurerm_application_insights` (workspace-based) | The Container Apps environment streams logs to Log Analytics; App Insights gives traces/metrics/charts. The App Insights connection string is injected into the container, so telemetry is wired to where the code runs. |
| 5 | "Private warehouse for Docker images - only our app can pull" | **Azure Container Registry** - `azurerm_container_registry` (`admin_enabled = false`) + `AcrPull` granted only to the app identity | A private registry with admin credentials disabled; the only principal that can pull is the app's managed identity. (Network-privacy caveat in §7.) |
| 6 | "Safe for passwords/keys/tokens - only our app, not on public internet" | **Azure Key Vault** - `azurerm_key_vault` (`rbac_authorization_enabled = true`, `network_acls` default-Deny) + **Key Vault Secrets User** role + **private endpoint** | Dedicated secrets store. RBAC (not legacy access policies) scopes access to the app identity; default-deny firewall + private endpoint keep it off the public internet. |
| 7 | "Our private territory - isolated network, our own little data center" | **Virtual Network `10.0.0.0/16`** with segmented subnets (`snet-container-app` delegated, `snet-private-endpoints`) + **3 Private DNS Zones** + **vnet links** + **Private Endpoints** | The whole estate lives in one VNet; PaaS services are reached over private endpoints with private DNS resolution - the cloud equivalent of a self-contained data centre. |
| 8 | "Structured data… they know SQL Server… inside network only, no public endpoints" | **Azure SQL Database** - `azurerm_mssql_server` (Entra-only auth, `public_network_access_enabled = false`) + `azurerm_mssql_database` + **private endpoint** + `privatelink.database.windows.net` zone | Managed PaaS SQL - familiar T-SQL for the devs, no server to maintain. Public access disabled; reachable only via the private endpoint. Passwordless via Entra (`azuread_authentication_only = true`). |
| 9 | "User files / photos - private, through our network, app sees it as a regular folder" | **Azure Files** - `azurerm_storage_share` on `azurerm_storage_account` (`public_network_access_enabled = false`) + **private endpoint** (`file` subresource) + `privatelink.file.core.windows.net` zone | An SMB file share can be mounted as a normal folder inside the container. Private-only access via the file private endpoint. |
| 10 | "Terraform state shouldn't live on a laptop - store it reliably in the cloud" | **Azure Blob Storage backend** - `backend "azurerm"` (storage account `sttfstateyurko01`, container `tfstate`, key `dev.tfstate`) | Remote state in Blob Storage with native lease-based locking - durable, shared across the team, and recoverable. |

---


## 3. Work done - module breakdown

The configuration is split into **9 reusable modules**, each with `main`/`variables`/`outputs`, consistent naming (`rg-`, `vnet-`, `snet-`, `kv-`, `sql-`, `cae-`, `ca-`…) and tagging:

| Module | Resources created |
|--------|-------------------|
| `resource_group` | `azurerm_resource_group` |
| `network` | VNet + delegated Container Apps subnet + private-endpoints subnet |
| `monitoring` | Log Analytics workspace + workspace-based Application Insights |
| `acr` | Container Registry (admin disabled) |
| `storage` | Storage account (public access off) + Azure File share `uploads` |
| `sql` | SQL logical server (Entra-only auth, public off) + SQL database |
| `container_app` | Container Apps environment (internal, workload-profiles) + Container App + User-Assigned Identity, with App Insights env var and ACR `registry{}` block |
| `security` | Key Vault (RBAC + deny-by-default) + 3 Private DNS zones + vnet links + role assignments (`AcrPull`, `Key Vault Secrets User`, admin) |
| `private_endpoints` | Private endpoints for SQL (`sqlServer`), Storage (`file`), Key Vault (`vault`), each with its DNS zone group |

Root `main.tf` wires the modules together; cross-module dependencies (identity → role assignments, DNS zone IDs → private endpoints) are passed explicitly through outputs/variables.

---

## 4. Security posture (how "private + passwordless" is achieved)

- **Passwordless everywhere:** one User-Assigned Managed Identity authenticates to ACR (`AcrPull`), Key Vault (`Key Vault Secrets User`) and SQL (Entra admin, SQL auth disabled). No connection strings or keys in the codebase.
- **No public data planes:** SQL and Storage have `public_network_access_enabled = false`; Key Vault is default-deny with a single allowed runner IP for pipeline management.
- **Private connectivity:** SQL, Files and Key Vault are reached over private endpoints with matching Private DNS zones, so service FQDNs resolve to private IPs inside the VNet.
- **Compute isolation:** the Container Apps environment is internal (no public IP).
- **Registry hardening:** ACR admin account disabled; pull restricted to the app identity.

---

## 5. State management

Remote backend configured in `backend.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-tfstate"
  storage_account_name = "sttfstateyurko01"
  container_name       = "tfstate"
  key                  = "dev.tfstate"
}
```

State is stored durably in Azure Blob Storage with lease-based locking - never on a developer laptop.

---


## 6. How to deploy

Required inputs (`terraform.tfvars`): `project_name`, `environment`, `location`, `runner_ip`, `sql_aad_admin_login`, `sql_aad_admin_object_id`.

```bash
terraform init      
terraform plan
terraform apply
```



### Post-deployment SQL configuration

After deployment, a database user for the managed identity must be created from within the private network.

Connect to the Azure SQL Database using a Microsoft Entra ID administrator account and execute the following commands:

```sql
CREATE USER [id-bestrong-dev]
FROM EXTERNAL PROVIDER;

ALTER ROLE db_datareader
ADD MEMBER [id-bestrong-dev];

ALTER ROLE db_datawriter
ADD MEMBER [id-bestrong-dev];
```

These commands create a database user for the managed identity and grant the application read and write permissions without requiring SQL usernames or passwords.

