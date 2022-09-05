
param keyVaultName string
param location string
param tenant string

@secure()
param secretUser string
@secure()
param userValue string
@secure()
param secretPassword string
@secure()
param passwordValue string

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    tenantId: tenant
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

resource secretUserResource 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: secretUser
  parent: keyVault
  properties: {
    value: userValue
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
