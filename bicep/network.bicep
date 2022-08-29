param location string = resourceGroup().location

param sopokeVnetName string = 'vnetSpoke'

param hubVnetName string = 'vnetHub'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource networkSecurityGroupStandard 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsgstandard'
  location: location
  properties: {
    
  }
}

var spokeConfig = {
  addressSpacePrefix: '10.200.0.0/24'
  subnetFirewall: 'subnetFirewall'
  subnetFirewallPrefix: '10.200.0.0/26'
  subnetVm : 'subnetVM'
  subnetVmPrefix: '10.200.0.64/27'
  subnetBastion : 'AzureBastionSubnet'
  subnetBastionPrefix: '10.200.0.96/27'
}
var hubConfig = {
  addressSpacePrefix: '10.240.0.0/16'
  subnetPrivateLinkName: 'subnetPrivateLink'
  subnetPrivateLinkPrefix: '10.240.0.0/22'
  subnetLoadBalancerName : 'subnetLoadBalancerName'
  subnetLoadBalancerPrefix : '10.240.4.0/24'
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
        name: spokeConfig.subnetFirewall
        properties: {
          addressPrefix: spokeConfig.subnetFirewallPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
        }
      }
      {
        name: spokeConfig.subnetVm
        properties: {
          addressPrefix: spokeConfig.subnetVmPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: spokeConfig.subnetBastion
        properties: {
          addressPrefix: spokeConfig.subnetBastionPrefix
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
        name: hubConfig.subnetPrivateLinkName
        properties: {
          addressPrefix: hubConfig.subnetPrivateLinkPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
        }
      }
      {
        name: hubConfig.subnetLoadBalancerName
        properties: {
          addressPrefix: hubConfig.subnetLoadBalancerPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupStandard.id
          }
        }
      }
    ]
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

