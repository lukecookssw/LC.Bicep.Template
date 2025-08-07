@description('Name of the App Service')
param appServicePrincipalId string

@description('Name of the Key Vault')
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appServicePrincipalId
        permissions: {
          secrets: [
            'get', 'list'
          ]
        }
      }
    ]
  }
}

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultName string = keyVault.name
