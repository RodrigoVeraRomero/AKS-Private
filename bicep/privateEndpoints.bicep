param privateKeyVaultName string
param privateStorageName string
param privateZoneName string
param location string
param subnetId string
param vnetId string
param keyVaultId string
param storageId string

resource privateEndpointKeyVault 'Microsoft.Network/privateEndpoints@2021-05-01' = {
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
            'keyvault'
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
            'storage'
          ]
        }
      }
    ]
  }
 
}

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateZoneName
  location: 'global'
  properties: {}
  
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZone
  name: '${privateZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateZoneName}Group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointKeyVault
    privateEndpointStorage
  ]
}
