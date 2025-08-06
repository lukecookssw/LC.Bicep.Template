param name string
param appServicePlanId string

resource appService 'Microsoft.Web/sites@2024-11-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
  }
}
output appServiceId string = appService.id
output appServiceUrl string = 'https://${appService.name}.azurewebsites.net'
