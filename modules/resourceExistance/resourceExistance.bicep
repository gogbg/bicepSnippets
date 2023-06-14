@description('Specify the name of the deploymentScript')
param name string

@description('Specify location of the deploymentScript')
param location string

@description('Specify the name of the user-assigned managed identity that has permissions to list aad groups')
param uamiName string

@description('Specify unique guid to execute the deploymentScript everytime (default). Or specify the previous guid to run it only once')
param rerun string = newGuid()

@description('Specify the id of the resource')
param resourceId array

@description('Specify the properties you want to retrieve in case the object exists in powershell, where the resource is referenced by the $res variable. Example: @{tags={$res.tags}}')
param propertyMap string = ''

var resourceIdAsString = '\'${join(resourceId, '\',\'')}\''

resource deploymentId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  kind: 'AzurePowerShell'
  location: location
  properties: {
    forceUpdateTag: rerun
    azPowerShellVersion: '8.2'
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
    scriptContent: loadTextContent('Get-Resource.ps1')
    arguments: (propertyMap != '' ? '-Id ${resourceIdAsString} -PropertyMap ${propertyMap}' : '-Id ${resourceIdAsString}')
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deploymentId.id}': {}
    }
  }
}

output res object = deploymentScript.properties.outputs
