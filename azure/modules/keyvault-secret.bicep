param keyVaultName string

param secretName string

@secure()
param secretValue string

resource kv 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  name: secretName
  parent: kv
  properties: {
    value: secretValue
  }
}
