targetScope='resourceGroup'

/*
 * Input parameters
*/

@description('The subnet resource id to use for APIM.')
@minLength(1)
param apimSubnetId string

@description('The email address of the publisher of the APIM resource.')
@minLength(1)
param publisherEmail string = 'apim@demo.com'

@description('Company name of the publisher of the APIM resource.')
@minLength(1)
param publisherName string = 'Demo Company'

@description('The pricing tier of the APIM resource.')
param skuName string = 'Developer'

@description('The instance size of the APIM resource.')
param capacity int = 1

@description('Location for Azure resources.')
param location string = resourceGroup().location

param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string


/*
 * Variables
*/
param apimName string 

/*
 * Resources
*/

resource apimName_resource 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apimName
  location: location
  sku:{
    capacity: capacity
    name: skuName
  }
  properties:{
    virtualNetworkType: 'Internal'
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
  }
}

output  apiName string = apimName_resource.name

resource apimName_appInsightsLogger_resource 'Microsoft.ApiManagement/service/loggers@2019-01-01' = {
  parent: apimName_resource
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource apimName_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = {
  parent: apimName_resource
  name: 'applicationinsights'
  properties: {
    loggerId: apimName_appInsightsLogger_resource.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}



output privateIPAddress string= apimName_resource.properties.privateIPAddresses[0]
output ApimName string=apimName_resource.name
