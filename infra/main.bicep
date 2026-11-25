// Chapter 8 DevSecOps Lab
// Secure, low-cost Azure Storage Account

@description('Globally unique lowercase Storage Account name.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stch8devsecops001'

@description('Azure deployment region.')
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
  }
}

// Secure Azure Key Vault

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kvch8devsecops001'
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Disabled'
  }
}

// GitHub Actions Azure authentication identity

resource githubIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-ch8-github-actions'
  location: location
}

// GitHub Actions OIDC trust for the main branch

resource githubFederatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: githubIdentity
  name: 'github-main-branch'
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:AsadImam2/azure-ch8-devsecops-lab:ref:refs/heads/main'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}
