// create key vault with arm bicep
@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {}

@description('Salt')
param salt string = substring(uniqueString(resourceGroup().id), 0, 4)

param connectionStringsToAdd array = []

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

resource s 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for accountName in connectionStringsToAdd: {
  name: '${accountName}-Key'
  parent: keyVault
  properties: {
    value: listConnectionStrings(accountName, '2022-05-15').connectionStrings[0].connectionString
  }
}]

output keyVaultID string = keyVault.id
output keyVaultName string = keyVault.name

