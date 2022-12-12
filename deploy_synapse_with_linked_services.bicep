@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {
  Environment: 'Development'
  Application: 'synapse'
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


module synapseWorkspace './synapse/workspace.bicep' = {
  name: 'exampleSynapseWorkspace'
  scope: rg
  params: {
    location: location
    tags: tags
    salt: salt
  }
}
