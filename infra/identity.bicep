@description('Azure deployment region.')
param location string = resourceGroup().location

@description('Name of the GitHub Actions managed identity.')
param identityName string = 'id-ch8-github-actions'

resource githubIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

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
