param privateKeyVaultName string
param privateStorageName string
param location string
param subnetId string
param vnetSpokeId string
param vnetHubId string
param keyVaultId string
param storageId string

var keyVaultEndpoint  = 'privatelink.vaultcore.azure.net'
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

resource privateDnsZoneLinkVaultHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneVault
  name: '${keyVaultEndpoint}-Hub'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetHubId
    }
  }
}

resource privateDnsZoneLinkVaultSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneVault
  name: '${keyVaultEndpoint}-Spoke'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetSpokeId
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

resource privateDnsZoneLinkFileHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneFile
  name: '${fileEndpoint}-Hub'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetHubId
    }
  }
}

resource privateDnsZoneLinkFileSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneFile
  name: '${fileEndpoint}-Spoke'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetSpokeId
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
