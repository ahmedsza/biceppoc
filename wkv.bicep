param kvname string
resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvname
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    accessPolicies: [
      // {
      //   tenantId: 'string'
      //   objectId: 'string'
      //   applicationId: 'string'
      //   permissions: {
      //     keys: [
      //       'string'
      //     ]
      //     secrets: [
      //       'string'
      //     ]
      //     certificates: [
      //       'string'
      //     ]
      //     storage: [
      //       'string'
      //     ]
      //   }
      // }
    ]
  }
}

output kvname string =key_vault.name
