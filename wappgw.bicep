/*
 * Input parameters
*/
@description('The name of the Application Gateawy to be created.')
param appGatewayName            string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
@secure()
param appGatewayFQDN            string

@description('The location of the Application Gateawy to be created')
param location                  string = resourceGroup().location

@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId        string

@description('The backend URL of the APIM.')
param primaryBackendEndFQDN     string 

@description('The developer URL of the APIM.')
param PortalFQDN     string 

param hostName  string

@description('The Url for the Application Gateway Health Probe.')
param probeUrl                  string = '/status-0123456789abcdef'

@description('The pfx password file for the Application Gataeway TLS listener. (base64 encoded)')
param appGatewayCertificateData     string

param keyVaultName                  string
param keyVaultResourceGroupName     string

var namingStandard          = '${appGatewayName}-prod-${location}-001'
var appGatewayPrimaryPip    = 'pip-${namingStandard}'
var appGatewayIdentityId    = 'identity-${namingStandard}'
var primarySubnetId         = appGatewaySubnetId

/*
 * Implementation
*/
resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name:     appGatewayIdentityId
  location: location
}

module certificate 'wcert.bicep' = {
  name: 'certificate'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    objectId:       appGatewayIdentity.properties.principalId
    tenantId:       appGatewayIdentity.properties.tenantId
    keyVaultName:   keyVaultName
    certData:       appGatewayCertificateData
  }
}

resource appGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-09-01' = {
  name: appGatewayPrimaryPip
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource appGatewayName_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: appGatewayName
  location: location
  dependsOn: [
    appGatewayPublicIPAddress
    certificate
    appGatewayIdentity
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceGroup().id}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${appGatewayIdentityId}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: primarySubnetId
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: appGatewayFQDN
        properties: {
          keyVaultSecretId: certificate.outputs.secretUri
        }
      }
    ]
    trustedRootCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'apim'
        properties: {
          backendAddresses: [
            {
              fqdn: primaryBackendEndFQDN
            }
          ]
        }
      }

      {
        name: 'apimportal'
        properties: {
          backendAddresses: [
            {
              fqdn: PortalFQDN
            }
          ]
        }
      }

    ]
    backendHttpSettingsCollection: [
      {
        name: 'default'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
      {
        name: 'https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: primaryBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/probes/APIM'
          }
        }
      }

      {
        name: 'httpsportal'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: PortalFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/probes/APIMPortal'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'default'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostnames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'https'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/sslCertificates/${appGatewayFQDN}'
          }
          hostName: 'api.${hostName}'
          hostnames: []
          requireServerNameIndication: false
        }
      }

      {
        name: 'httpsportal'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/sslCertificates/${appGatewayFQDN}'
          }
          hostName: 'portal.${hostName}'
          hostnames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'apim'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/httpListeners/https'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendAddressPools/apim'
          }
          backendHttpSettings: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendHttpSettingsCollection/https'
          }
        }
      }

      {
        name: 'apimportal'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/httpListeners/httpsportal'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendAddressPools/apimportal'
          }
          backendHttpSettings: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGatewayName)}/backendHttpSettingsCollection/httpsportal'
          }
        }
      }

    ]
    probes: [
      {
        name: 'APIM'
        properties: {
          protocol: 'Https'
          host: primaryBackendEndFQDN
          path: probeUrl
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }

      {
        name: 'APIMPortal'
        properties: {
          protocol: 'Https'
          host: PortalFQDN
          path: '/signin'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
  }
}
