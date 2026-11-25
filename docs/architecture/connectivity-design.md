# Azure DevSecOps Lab — Connectivity Design

## 1. Purpose

This document defines the secure, low-cost connectivity architecture for the Chapter 8 Azure DevSecOps lab.

The design separates Azure control-plane access from Storage and Key Vault data-plane access.

## 2. Architecture Overview

The architecture consists of:

1. GitHub repository — source code, Bicep infrastructure, security policies and CI/CD workflows.
2. GitHub Actions — CI checks, security scanning, policy validation and controlled deployment.
3. GitHub OIDC — passwordless authentication between GitHub Actions and Microsoft Entra ID.
4. Azure Resource Manager — Azure infrastructure deployment and management.
5. Azure Storage Account — private storage for future lab artifacts or application data.
6. Azure Key Vault — secure storage for future application secrets.
7. User-assigned Managed Identity — identity used for GitHub Actions federation and Azure authentication.

## 3. GitHub Actions Authentication

- Use GitHub-hosted runners initially.
- Authenticate to Azure using OpenID Connect (OIDC).
- Do not store a permanent Azure client secret in GitHub repository secrets.
- Grant `id-token: write` only to the workflow job that needs an OIDC token.
- Restrict the federated identity credential to the approved repository and main branch.
- Use least-privilege Azure RBAC permissions.
- Review deployment permissions before assigning any role.

The current federated identity subject is:

`repo:AsadImam2/azure-ch8-devsecops-lab:ref:refs/heads/main`

## 4. Azure Control Plane and Data Plane

These are separate access paths.

### 4.1 Azure Control Plane

GitHub Actions will authenticate through OIDC and use Azure Resource Manager for approved infrastructure operations.

Resource deployment permissions will be scoped to the lab Resource Group wherever possible.

### 4.2 Azure Storage Data Plane

The Storage Account will initially use:

- Public network access disabled.
- Anonymous blob access disabled.
- Shared Key authentication disabled.
- HTTPS required.
- TLS 1.2 minimum.
- Microsoft-managed encryption.
- Standard locally redundant storage (LRS).
- Microsoft Entra ID and RBAC for authorized data access.

GitHub-hosted runners will not access private Storage data directly while public network access remains disabled.

GitHub Actions Artifacts will initially hold CI build outputs and reports where appropriate.

### 4.3 Azure Key Vault Data Plane

The Key Vault will initially use:

- Public network access disabled.
- Azure RBAC authorization.
- Soft delete.
- Purge protection.
- Least-privilege access.

GitHub-hosted runners will not retrieve Key Vault secrets directly under the initial network design.

Future Azure-hosted workloads may use Managed Identity to access Key Vault when a suitable private connectivity path is available.

## 5. Network Connectivity Strategy

Private Endpoints and Virtual Networks will not be created in the initial phase.

Reasons:

- Avoid unnecessary Azure charges.
- Avoid unnecessary networking complexity.
- Keep the initial learning environment small.
- Preserve the approved private-network security settings.

If a future requirement needs GitHub Actions to access private Storage or Key Vault data, the connectivity architecture must be reviewed before implementation.

Possible approaches include a suitably secured self-hosted runner inside an Azure network or another approved private connectivity solution.

No approach will be implemented without reviewing security, operational complexity and cost.

## 6. Identity and Authorization

- OIDC establishes trust; it does not automatically grant Azure resource permissions.
- Azure RBAC assignments must be configured and verified separately.
- GitHub Actions receives only the permissions needed for its approved deployment tasks.
- Storage data permissions and Key Vault secret permissions remain separate.
- No broad subscription-wide permissions will be assigned without a documented requirement and approval.

## 7. Security Pipeline

The intended GitHub Actions pipeline includes:

1. Source code security scanning.
2. Secret scanning.
3. Infrastructure-as-Code scanning.
4. OPA/Conftest policy validation.
5. Dependency and SAST checks.
6. Security gates that block deployment on required failures.
7. Controlled Azure deployment through OIDC.
8. Deployment verification.

## 8. Cost Controls

The initial design avoids:

- Azure Virtual Machines.
- Private Endpoints.
- Unnecessary Virtual Networks.
- Azure Sentinel.
- Paid Log Analytics ingestion.
- Unnecessary storage uploads and data operations.

Any additional paid Azure service requires a cost review before creation.

## 9. Current Limitations

- Storage Account data-plane connectivity from GitHub-hosted runners is not implemented.
- Key Vault data-plane connectivity from GitHub-hosted runners is not implemented.
- OIDC federation does not yet have verified Azure RBAC deployment permissions.
- No Azure infrastructure has been deployed as part of this design documentation step.

These limitations are intentional and must not be represented as completed functionality.

## 10. Deployment Safety

- Bicep compilation, Azure validation and What-If preview are pre-deployment checks.
- What-If does not create the listed resources.
- Actual Azure deployment requires explicit user approval.
- Deployment results must be verified before marking infrastructure tasks complete.

## 11. Design Status

Status: Approved design direction, pending implementation and verification.

This document records the initial connectivity architecture for the Azure Chapter 8 DevSecOps lab.
