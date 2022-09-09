
param keyVaultName string
param location string
param tenant string

@secure()
param secretPassword string
@secure()
param passwordValue string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    tenantId: tenant
    publicNetworkAccess: 'Disabled'
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource secretPasswordResource 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: secretPassword
  parent: keyVault
  properties: {
    value: passwordValue
    }
}

output keyvaultId string = keyVault.id
