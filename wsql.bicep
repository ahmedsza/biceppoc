//var webSiteName = 'webSite${uniqueString(resourceGroup().id)}'
var sqlserverName = 'sqlserver${uniqueString(resourceGroup().id)}'
var databaseName = 'sampledb'

// Data params
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

// Data resources
resource sqlserver 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlserverName
  location: resourceGroup().location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  name: '${sqlserver.name}/${databaseName}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlserverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  name: '${sqlserver.name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output dbname string = databaseName
output fqdn string =sqlserver.properties.fullyQualifiedDomainName

