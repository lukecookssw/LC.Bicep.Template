targetScope = 'subscription'

// Only parameter - the environment to deploy to
@description('Environment for the deployment (Dev, Staging, Production)')
param environment string

// Fixed configuration values
var resourceGroupName = 'LC.Api'
var location = 'australiaeast'
var fullResourceGroupName = '${resourceGroupName}.${environment}'

// Create the resource group for the API
@description('Resource group for the given environment')
module resourceGroupModule 'modules/resource-group.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    environment: environment
    location: location
  }
}

// Create the app service plan in the resource group
@description('App service plan for hosting applications')
module appServicePlanModule 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanDeployment'
  scope: resourceGroup(fullResourceGroupName)
  dependsOn: [
    resourceGroupModule
  ]
  params: {
    name: 'LC-Api-Plan-${environment}'
  }
}

// Create the app service in the resource group
@description('App service for hosting the API')
module appServiceModule 'modules/app-service.bicep' = {
  name: 'appServiceDeployment'
  scope: resourceGroup(fullResourceGroupName)
  dependsOn: [
    resourceGroupModule
  ]
  params: {
    name: 'LC-Api-${environment}'
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}

// Create the Key Vault in the resource group
@description('Key Vault for storing secrets')
module keyVaultModule 'modules/key-vault.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup(fullResourceGroupName)
  dependsOn: [
    resourceGroupModule
  ]
  params: {
    appServicePrincipalId: appServiceModule.outputs.appServicePrincipalId
    keyVaultName: 'LC-Api-KV-${environment}'
  }
}

// Create the SQL Server in the resource group
@description('SQL Server and database for the API')
module sqlServerModule 'modules/sql-server.bicep' = {
  name: 'sqlServerDeployment'
  scope: resourceGroup(fullResourceGroupName)
  dependsOn: [
    resourceGroupModule
  ]
  params: {
    environment: environment
    userAssignedIdentityResourceId: appServiceModule.outputs.appServicePrincipalId
  }
}

// add connection string to Key Vault
@description('Store SQL connection string in Key Vault')
module keyVaultSecretModule 'modules/keyvault-secret.bicep' = {
  name: 'keyVaultSecretDeployment'
  scope: resourceGroup(fullResourceGroupName)
  dependsOn: [
    resourceGroupModule
    sqlServerModule
    keyVaultModule
  ]
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    secretName: 'SqlConnectionString'
    secretValue: sqlServerModule.outputs.sqlConnectionString
  }
}
