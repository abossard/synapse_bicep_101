@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {
  Environment: 'Production'
  Application: 'PowerBIEmbedded'
}

@description('Salt')
param salt string = substring(uniqueString(subscription().id), 0, 4)

@description('The name of the resource group that will be created.')
param resourceGroupName string = 'rg-synapse-test-${salt}'

@description('The subnets to be deployed, can be a JSON object or it takes the default: subnets.json')
param synapseWorkspaces object = loadJsonContent('./synapse_workspaces.json')

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module exampleKeyVault './example_resources/keyvault.bicep' = {
  name: 'exampleKeyVault'
  scope: rg
  params: {
    location: location
    tags: tags
  }
}


module cosmosDB './example_resources/cosmos_mongo.bicep' = {
  name: 'exampleCosmosDB'
  scope: rg
  params: {
    location: location
    tags: tags
    collection1Name: 'collection1'
    collection2Name: 'collection2'
    databaseName: 'database1'
  }
}
