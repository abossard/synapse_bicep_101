// create key vault with arm bicep
@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {}

@description('Salt')
param salt string = substring(uniqueString(resourceGroup().id), 0, 4)

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-${salt}'
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: '00000000-0000-0000-0000-000000000000'
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

output keyVault object = keyVault

