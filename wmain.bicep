targetScope='subscription'


param location string = 'southafricanorth'
// @secure()
// param adminPassword string
// param frontDoorEndpointName string = 'afd-${uniqueString(subscription().id)}'

// put in username
param sqlAdministratorLogin string 
//put in password
param sqlAdministratorLoginPassword string 

// get this value from the script
param appGatewayCertificateData string= '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'
// use the same value that you see in the script. it will be api followed by name in script
param appGatewayFQDN string='api.apimdemo.net'

param hostName string='apimdemo.net'

var number ='8'
var rgName  = 'rg-apime2e${number}'
var apimName = 'pocdemo${number}'
var kvname  ='pocdemokvd${number}'
var apisitename  ='pocapid${number}'
var websitename ='pocwebd${number}'
var appGatewayName ='pocgw${number}'
var ainame='pocai${number}'
var lawsname='poclaws${number}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  location: location
  name: rgName
}

module sqlserver 'wsql.bicep'={
  name:'sqlserver'
  scope: rg
 params: {
   sqlAdministratorLogin: sqlAdministratorLogin
   sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
 }
}

module userid 'wuserid.bicep'={
  name: 'manageduserid'
  scope: rg
}

module vnet 'wnetwork.bicep'={
  scope: rg
  name: 'vnet' 
  params: {
    networkName: 'vnet-webapp'
  }
  
}








module privateDns 'wdns.bicep'={
  scope: rg
  name: 'privateDns'
  params: {
    vnetId: vnet.outputs.id
  }
  
}

module apimprivateDns 'wprivatedns.bicep' = {
  scope: rg
  name: 'azure-api.net'
  params: {
    apimIPAddress: apimModule.outputs.privateIPAddress
    virtualNetworks_vnet_webapp_externalid: vnet.outputs.id
    apimName: apimModule.outputs.ApimName
  }
}
module webapp 'wAppService.bicep'={
  scope: rg
  name: 'web-app'
  params: {
    defaultSubnet: vnet.outputs.defaultSubnetId
    dnsZoneId: privateDns.outputs.id
    userid: userid.outputs.userid
    fqdn: sqlserver.outputs.fqdn
    databaseName: sqlserver.outputs.dbname
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    apisitename: apisitename
    websitename: websitename
  }
  
}

module azmon 'wazmon.bicep'={ 
  name: 'azmonitor'
  scope: rg
  params: {
    lawsname: lawsname
    ainame: ainame
  }
}

module apimModule 'wapim.bicep'  = {
  name: 'apimDeploy'
  scope:  rg
  params: {
    apimSubnetId: vnet.outputs.APIMSubnetId
    appInsightsName: azmon.outputs.appInsightsName
    appInsightsId: azmon.outputs.appInsightsId
    appInsightsInstrumentationKey: azmon.outputs.appInsightsInstrumentationKey
    apimName:  apimName
  }
}

module kv 'wkv.bicep'={
  name: 'kv'
  scope: rg
  params: {
    kvname: kvname
  }
}

module appgwModule 'wappgw.bicep' = {
  name: 'appgwDeploy'
  scope: rg
  dependsOn: [
    apimModule
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFQDN
    hostName:                       hostName
    location:                       location
    appGatewaySubnetId:             vnet.outputs.appgatewaySubnetId
    primaryBackendEndFQDN:          '${apimModule.outputs.apiName}.azure-api.net'
    PortalFQDN:                      '${apimModule.outputs.apiName}.developer.azure-api.net'
    appGatewayCertificateData:      appGatewayCertificateData
    keyVaultName:                   kv.outputs.kvname
    keyVaultResourceGroupName:      rg.name
  }
}

  
