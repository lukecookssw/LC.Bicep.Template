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
    login: appServicePrincipalId
    sid: appServicePrincipalId
    tenantId: subscription().tenantId
  }
}

//output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=WebApiDb;Persist Security Info=False; Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
output sqlConnectionString string = 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=WebApiDb;Persist Security Info=False;Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
