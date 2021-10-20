param privateDnsZones_azure_api_net_name string = 'azure-api.net'
param virtualNetworks_vnet_webapp_externalid string 
param apimIPAddress string
param apimName string

resource privateDnsZones_azure_api_net_name_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZones_azure_api_net_name
  location: 'global'
  
}

resource privateDnsZones_azure_api_net_name_apim_gw 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateDnsZones_azure_api_net_name_resource
  name: apimName
  properties: {
    ttl: 20
    aRecords: [
      {
        ipv4Address: apimIPAddress
      }
    ]
  }
}

resource privateDnsZones_azure_api_net_name_apim_portal 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privateDnsZones_azure_api_net_name_resource
  name: '${apimName}.developer'
  properties: {
    ttl: 20
    aRecords: [
      {
        ipv4Address: apimIPAddress
      }
    ]
  }
}

resource Microsoft_Network_privateDnsZones_SOA_privateDnsZones_azure_api_net_name 'Microsoft.Network/privateDnsZones/SOA@2018-09-01' = {
  parent: privateDnsZones_azure_api_net_name_resource
  name: '@'
  properties: {
    ttl: 3600
    soaRecord: {
      email: 'azureprivatedns-host.microsoft.com'
      expireTime: 2419200
      host: 'azureprivatedns.net'
      minimumTtl: 10
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
  }
}

resource privateDnsZones_azure_api_net_name_privatedns 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones_azure_api_net_name_resource
  name: 'apimdemoprivatedns'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworks_vnet_webapp_externalid
    }
  }
}
