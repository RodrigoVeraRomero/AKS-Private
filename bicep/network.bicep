param location string = resourceGroup().location
param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'
param routeTableName string


var hubConfig = {
  addressSpacePrefix: '10.200.0.0/24'
  subnetFirewall: 'SubnetFirewall'
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
  subnetPrivateLinkPrefix: '10.240.0.0/26'
  subnetLoadBalancerName : 'SubnetLoadBalancerName'
  subnetLoadBalancerPrefix : '10.240.0.64/26'
}

resource networkSecurityGroupStandard 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsgstandard'
  location: location
  properties: {
    
  }
}

resource routeTable 'Microsoft.Network/routeTables@2021-03-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'FirewallDefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubConfig.hopeIdAddress
        }
      }
    ]
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
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
        }
      }
      {
        name: hubConfig.subnetVm
        properties: {
          addressPrefix: hubConfig.subnetVmPrefix
        }
      }
      {
        name: hubConfig.subnetBastion
        properties: {
          addressPrefix: hubConfig.subnetBastionPrefix
        }
      }
      {
        name: hubConfig.serversSubnet
        properties: {
          addressPrefix: hubConfig.serversSubnetPrefix
          routeTable: {
            id: routeTable.id
          }
          
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
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
        name: spokeConfig.subnetPrivateLinkName
        properties: {
          addressPrefix: spokeConfig.subnetPrivateLinkPrefix
        }
      }
      {
        name: spokeConfig.subnetLoadBalancerName
        properties: {
          addressPrefix: spokeConfig.subnetLoadBalancerPrefix
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
