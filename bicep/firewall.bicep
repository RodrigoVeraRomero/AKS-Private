param firewallName string
param subnetfirewall string
param publicFirewallIpName string
param routeTableName string

param location string = resourceGroup().location



resource publicFirewallIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicFirewallIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: firewallName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'firewallPublicIP'
        properties: {
          subnet: {
            id: subnetfirewall
          }
          publicIPAddress: {
            id: publicFirewallIPAddress.id
          }
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'AKS-egress'
        properties: {
          priority: 102
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'Egress'
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }                
              ]
              targetFqdns: [
                '*.docker.io' 
              ]
              sourceAddresses: [
                '10.200.0.0/24'
                '10.240.0.0/16'
              ]
            }
            {
              name: 'AKS-FQDN'
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }                
                {
                  port: 443
                  protocolType: 'Https'
                }                
              ]
              targetFqdns: []
              fqdnTags: [
                'AzureKubernetesService'
              ]
              sourceAddresses: [
                '10.200.0.0/24'
                '10.240.0.0/16'
              ]
            }                                   
          ]
        }
      }          
    ]
    networkRuleCollections: [
      {
      name: 'AKS'
      properties: {
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'UDPAKS'
            protocols: [
              'UDP'
            ]
            sourceAddresses: [
              '10.200.0.0/24'
              '10.240.0.0/16'
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '123'
            ]
          }
        ]
      }
      }

    ]
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
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}
