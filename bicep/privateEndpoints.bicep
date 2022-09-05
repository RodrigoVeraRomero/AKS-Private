param privateKeyVaultName string
param privateStorageName string
param location string
param subnetId string
param vnetId string
param keyVaultId string
param storageId string

var keyVaultEndpoint  = 'privatelink.vault.azure.net'
var fileEndpoint  = 'privatelink.file.core.windows.net'

resource privateEndpointKeyVault 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateKeyVaultName
  location: location
  properties: {
    subnet: {
     id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateKeyVaultName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
 
}

resource privateEndpointStorage 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateStorageName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateStorageName
        properties: {
          privateLinkServiceId: storageId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
 
}

resource privateZoneVault 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: keyVaultEndpoint
  location: 'global'
  properties: {}
  
}

resource privateDnsZoneLinkVault 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneVault
  name: '${keyVaultEndpoint}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroupVault 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateKeyVaultName}/groupvault'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateZoneVault.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointKeyVault
  ]
}




resource privateZoneFile 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: fileEndpoint
  location: 'global'
  properties: {}
  
}

resource privateDnsZoneLinkFile 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneFile
  name: '${fileEndpoint}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroupFile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateStorageName}/groupfile'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateZoneFile.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointStorage
  ]
}
