param location string = resourceGroup().location
param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'



var hubConfig = {
  addressSpacePrefix: '10.200.0.0/24'
  subnetFirewall: 'AzureFirewallSubnet'
  subnetFirewallPrefix: '10.200.0.0/26'
  subnetVm : 'SubnetVM'
  subnetVmPrefix: '10.200.0.64/26'
  subnetBastion : 'AzureBastionSubnet'
  subnetBastionPrefix: '10.200.0.128/26'
  serversSubnet : 'ServerSubnet'
  serversSubnetPrefix: '10.200.0.192/26'
  hopeIdAddress: '10.200.0.195'
}
var spokeConfig = {
  addressSpacePrefix: '10.240.0.0/16'
  subnetPrivateLinkName: 'SubnetPrivateLink'
  subnetPrivateLinkPrefix: '10.240.8.0/26'
  subnetAKSName : 'SubnetAKS'
  subnetAKSPrefix : '10.240.0.0/21'
}

resource networkSecurityGroupStandard 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsgstandard'
  location: location
  properties: {
    
  }
}

resource vnetHub 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubConfig.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: hubConfig.subnetFirewall
        properties: {
          addressPrefix: hubConfig.subnetFirewallPrefix
        }
      }
      {
        name: hubConfig.subnetVm
        properties: {
          addressPrefix: hubConfig.subnetVmPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
        }
       
      }
      {
        name: hubConfig.subnetBastion
        properties: {
          addressPrefix: hubConfig.subnetBastionPrefix
        }
      }
    ]
  }
}


resource vnetSpoke 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: sopokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeConfig.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: spokeConfig.subnetAKSName
        properties: {
          addressPrefix: spokeConfig.subnetAKSPrefix
        }
      }
      {
        name: spokeConfig.subnetPrivateLinkName
        properties: {
          addressPrefix: spokeConfig.subnetPrivateLinkPrefix
        }
      }
      
    ]
  }
}

resource VnetPeeringSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnetSpoke
  name: '${sopokeVnetName}-${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}

resource VnetPeeringSHubSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnetHub
  name: '${hubVnetName}-${sopokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpoke.id
    }
  }
}

output vnetSpoke object = vnetSpoke
output vnetHub object = vnetHub
output vnetSpokeId string = vnetSpoke.id
output vnetHubId string = vnetHub.id
output spokeId string = vnetSpoke.id
output nsg string = networkSecurityGroupStandard.id

