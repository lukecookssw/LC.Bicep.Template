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
  params: {
    name: 'LC-Api-Plan.${environment}'
  }
}

// Create the app service in the resource group
@description('App service for hosting the API')
module appServiceModule 'modules/app-service.bicep' = {
  name: 'appServiceDeployment'
  scope: resourceGroup(fullResourceGroupName)
  params: {
    name: 'LC-Api-${environment}'
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}
