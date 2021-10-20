resource webplan 'Microsoft.Web/serverfarms@2021-01-15'={
  name: 'web-plan'
  location: 'westeurope'
  sku:{
    name : 'P1v2'
    tier :'PremiumV2'
    size :'P1v2'
    family: 'Pv2'
    capacity: 3
  }
  kind: 'app'
  properties: {
    zoneRedundant: true
  }
}
