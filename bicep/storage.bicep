
param storageName string
param location string
param fileShareName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: true
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
}

output storageAccountID string = storageAccount.id
output storagekey object = storageAccount
