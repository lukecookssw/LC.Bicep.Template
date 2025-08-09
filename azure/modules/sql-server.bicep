@description('Dev, Staging, Production')
param environment string

param appServicePrincipalId string

var location string = resourceGroup().location

resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: 'WebApiSqlServer-${environment}'
  location: location
  properties: {
    administratorLogin: 'sqlAdmin'
    administratorLoginPassword: 'sqlPW!2@23iuhFDFDaf23987@#%1' // TODO: Replace with a secure password https://fnbk.medium.com/generating-secure-random-passwords-in-azure-bicep-templates-755e962ec639
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource databaseFirewall 'Microsoft.Sql/servers/firewallRules@2024-11-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
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

// Add the managed identity as a SQL Server AAD Administrator
resource aadAdmin 'Microsoft.Sql/servers/administrators@2024-11-01-preview' = {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'github-deployment-sp'
    sid: '83a26b28-88cd-430b-b09b-e0198c5d6a33'
    tenantId: subscription().tenantId
  }
}

// Grant Directory Reader role to the SQL Server's managed identity
// resource sqlServerDirectoryReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(sqlServer.id, 'Directory Reader')
//   scope: tenant()
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '88d8e3e3-8f55-4a1e-953a-9b9898b8876b') // Directory Readers role
//     principalId: sqlServer.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

//output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=WebApiDb;Persist Security Info=False; Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
output sqlConnectionString string = 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=WebApiDb;Persist Security Info=False;Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
