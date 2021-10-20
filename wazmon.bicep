targetScope='resourceGroup'
param location string =resourceGroup().location
param lawsname string
param ainame string


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: lawsname
  location: location

  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}


resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: ainame
  location: location
  kind: 'string'

  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString

output appInsightsName string = appInsights.name
output appInsightsId string = appInsights.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
