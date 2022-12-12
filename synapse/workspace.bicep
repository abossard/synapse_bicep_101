// create key vault with arm bicep
@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {}

@description('Salt')
param salt string = substring(uniqueString(resourceGroup().id), 0, 4)


module exampleKeyVault '../example_resources/keyvault.bicep' = {
  name: 'exampleKeyVault'
  scope: resourceGroup()
  dependsOn: [
    cosmosDB
  ]
  params: {
    location: location
    tags: tags
    connectionStringsToAdd: [
      //cosmosDB.outputs.cosmosDBAccountName
    ]
  }
}

var cosmosDBAccountName = 'mongodb-${salt}'
var cosmosDBDatabaseName = 'database1'
module cosmosDB '../example_resources/cosmos_mongo.bicep' = {
  name: 'exampleCosmosDB'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    accountName: cosmosDBAccountName
    collection1Name: 'collection1'
    collection2Name: 'collection2'
    databaseName: cosmosDBDatabaseName
  }
}


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

resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' ={
  name: 'DeploymentScriptUser-${salt}'
  location: location
  tags: tags
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


module postDeploymentScript './PostDeploymentScripts.bicep' = {
  name: 'postDeploymentScript-${salt}'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    salt: salt
    deploymentScriptUAMIId: userAssignedManagedIdentity.properties.principalId
    cosmosDBAccountName: cosmosDBAccountName
    cosmosDBAccountID: cosmosDB.outputs.cosmosDBAccountID
    cosmosDBDatabaseName: cosmosDBDatabaseName
    ctrlDeployCosmosDB: true
    keyVaultID: exampleKeyVault.outputs.keyVaultID
    keyVaultName: exampleKeyVault.outputs.keyVaultName
    synapseWorkspaceID: synapseWorkspace.id
    synapseWorkspaceName: synapseWorkspace.name
    workspaceDataLakeAccountID: datalakeStorage.id
    workspaceDataLakeAccountName: datalakeStorage.name
    ctrlDeployAI: false
    networkIsolationMode: 'None'
  }
}
