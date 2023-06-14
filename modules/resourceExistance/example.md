# Example usage

## Prototype code to get the current accessPolicies of keyVault if it exists and pass them during the keyVault update so they are not erased.

```bicep
var kvResourceId = resourceId(subscription().subscriptionId, resourceGroupName, 'Microsoft.KeyVault/vaults', kvName)

module kvExist 'resourceExistance.bicep' = {
  name: 'check-kv-existance'
  params: {
    location: location
    name: 'test-kv-existance'
    uamiName: uamiName
    resourceId: [ kvResourceId ]
    propertyMap: '@{accessPolicies={$res.properties.accessPolicies}}'
  }
  scope: resourceGroup(resourceGroupName)
}

module keyVault 'keyVault.bicep' = {
  name: 'deploy-keyVault'
  params: {
    name: name
    location: location
    accessPolicies: kvExist.outputs.res[kvResourceId].exists ? union([], array(json(kvExist.outputs.res[kvResourceId].accessPolicies))) : []
    sku: sku
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    allowAzureServices: allowAzureServices
  }
  scope: resourceGroup(resourceGroupName)
}
```
