param resourceGroupName string
param location string
param environment string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceGroupName}.${environment}'
  location: location
  managedBy: 'Luke Cook'
  tags: {
    environment: environment
  }
}

output resourceGroupName string = rg.name
