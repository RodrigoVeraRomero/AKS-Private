param firewallName string
param subnetfirewall string
param publicIp string

param location string = resourceGroup().location

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
            id: publicIp
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
