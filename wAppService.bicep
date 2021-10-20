param defaultSubnet string
param dnsZoneId string
param userid string
param sqlAdministratorLogin string
param sqlAdministratorLoginPassword string
param databaseName string
param fqdn string

resource webpe 'Microsoft.Network/privateEndpoints@2021-02-01'={
  name: 'pe-web'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: defaultSubnet
    }
    privateLinkServiceConnections:[
      {
        name: 'pe-web'
        properties:{
          privateLinkServiceId: webapp.id
          groupIds: [
            'sites'
          ]

        }
      }
    ]
  }
  
}

// should declare this inside pe-web to not require dependsOn
// or use '${webpe.name}/web-geba in the name
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01'={
  name: '${webpe.name}/dnsgroupname'
  dependsOn: [
    webpe
  ]
  properties: {
    privateDnsZoneConfigs:[
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: dnsZoneId
        }
      }
    ]
  }
  
}



resource webpeapi 'Microsoft.Network/privateEndpoints@2021-02-01'={
  name: 'pe-webapi'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: defaultSubnet
    }
    privateLinkServiceConnections:[
      {
        name: 'pe-webapi'
        properties:{
          privateLinkServiceId: webappapi.id
          groupIds: [
            'sites'
          ]

        }
      }
    ]
  }
  
}

// should declare this inside pe-web to not require dependsOn
// or use '${webpe.name}/web-geba in the name
resource dnsZoneGroupapi 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01'={
  name: '${webpeapi.name}/dnsgroupname'
  dependsOn: [
    webpeapi
  ]
  properties: {
    privateDnsZoneConfigs:[
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: dnsZoneId
        }
      }
    ]
  }
  
}







resource webplan 'Microsoft.Web/serverfarms@2021-01-01'={
  name: 'web-plan'
  location: resourceGroup().location
  sku:{
    size: 'P2V2'
    name: 'P2V2'
  }
  
}

param websitename string
param apisitename string

resource webapp 'Microsoft.Web/sites@2021-01-01'={
  name: websitename
  location: resourceGroup().location
  properties:{
    serverFarmId: webplan.id
  
    httpsOnly: true
    siteConfig:{
      minTlsVersion: '1.2'

    }
    
  } 
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userid}': {}
    }
  }
}

resource webappapi 'Microsoft.Web/sites@2021-01-01'={
  name: apisitename
  location: resourceGroup().location
  properties:{
    serverFarmId: webplan.id
  
    httpsOnly: true
    siteConfig:{
      minTlsVersion: '1.2'

    }
    
  } 
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userid}': {}
    }
  }
}

resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${webapp.name}/connectionstrings'
  properties: {
    DefaultConnection: {
      value: 'Data Source=tcp:${fqdn},1433;Initial Catalog=${databaseName};User Id=${sqlAdministratorLogin}@${fqdn};Password=${sqlAdministratorLoginPassword};'
      type: 'SQLAzure'
    }
  }
}


output appHostName string = webapp.properties.defaultHostName
output appApiHostName string =webappapi.properties.defaultHostName
output appServiceResourceId string = webapp.id
output appServiceApiResourceId string = webappapi.id
