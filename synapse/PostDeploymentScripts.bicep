param location string = resourceGroup().location
param tags object = {}
param salt string
param deploymentScriptUAMIId string
@allowed([
  'None'
  'vNet'
])
param networkIsolationMode string = 'None'
param ctrlDeployAI bool = false
param keyVaultName string
param keyVaultID string
param synapseWorkspaceName string
param synapseWorkspaceID string
param ctrlDeployCosmosDB bool
param cosmosDBAccountID string
param cosmosDBAccountName string
param cosmosDBDatabaseName string
param workspaceDataLakeAccountName string
param workspaceDataLakeAccountID string

var synapseScriptArguments = [
  '-NetworkIsolationMode ${networkIsolationMode}'
  '-ctrlDeployAI ${ctrlDeployAI}'
  '-SubscriptionID ${subscription().subscriptionId}'
  '-ResourceGroupName ${resourceGroup().name}'
  '-ResourceGroupLocation ${location}'
  '-UAMIIdentityID ${deploymentScriptUAMIId}'
  '-KeyVaultName ${keyVaultName}'
  '-KeyVaultID ${keyVaultID}'
  '-SynapseWorkspaceName ${synapseWorkspaceName}'
  '-SynapseWorkspaceID ${synapseWorkspaceID}'
  '-CtrlDeployCosmosDB $${ctrlDeployCosmosDB}'
  '-CosmosDBAccountID ${cosmosDBAccountID} '
  '-CosmosDBAccountName ${cosmosDBAccountName} '
  '-CosmosDBDatabaseName ${cosmosDBDatabaseName}'
  '-WorkspaceDataLakeAccountName ${workspaceDataLakeAccountName} '
  '-WorkspaceDataLakeAccountID ${workspaceDataLakeAccountID}'
]

resource r_synapsePostDeployScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'SynapsePostDeploymentScript-${salt}'
  location: location
  kind: 'AzurePowerShell'
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deploymentScriptUAMIId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.2.4'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT30M'
    arguments: join(synapseScriptArguments, ' ')
    scriptContent: loadTextContent('./scripts/SynapsePostDeploy.ps1')
  }
}
