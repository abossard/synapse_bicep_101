// create key vault with arm bicep
@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {}

@description('Salt')
param salt string = substring(uniqueString(resourceGroup().id), 0, 4)

resource datalakeStorage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'datalk${salt}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
  }
  resource blob 'blobServices@2022-05-01' = {
    name: 'default'
    resource container 'containers@2022-05-01' = {
      name: 'datalake'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}


resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: 'synapse-${salt}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    azureADOnlyAuthentication: true
    defaultDataLakeStorage: {
      accountUrl: datalakeStorage.properties.primaryEndpoints.dfs
      filesystem: datalakeStorage::blob::container.name
    }
    managedVirtualNetwork: 'default'
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
  }
  resource sparkPool 'bigDataPools@2021-06-01' = {
    name: 'sparkpool'
    location: location
    properties: {
      autoPause: {
        delayInMinutes: 15
        enabled: true
      }
      autoScale: {
        enabled: true
        maxNodeCount: 3
        minNodeCount: 1
      }
      customLibraries: [
      ]
      nodeCount: 1
      nodeSizeFamily: 'MemoryOptimized'
      nodeSize: 'Small'
      sparkVersion: '3.3'
    }
  }
}
