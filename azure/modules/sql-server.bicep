@description('Dev, Staging, Production')
param environment string


@description('Resource ID of the User Assigned Managed Identity')
param userAssignedIdentityResourceId string

var location string = resourceGroup().location


resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: 'WebApiSqlServer-${environment}'
  location: location
  properties: {
    administratorLogin: 'sqlAdmin'
    administratorLoginPassword: uniqueString(resourceGroup().id) // TODO: Replace with a secure password https://fnbk.medium.com/generating-secure-random-passwords-in-azure-bicep-templates-755e962ec639
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-11-01-preview' = {
  parent: sqlServer
  name: 'WebApiDb'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
  }
}

//output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=WebApiDb;Persist Security Info=False; Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
output sqlConnectionString string = 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=WebApiDb;Persist Security Info=False;Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
