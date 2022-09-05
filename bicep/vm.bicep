
param location string = resourceGroup().location

param bastionSubnetId string

param machineName string 

param machineUser string 

param vmKey string 

@description('VM subnet')
param vmSubnetId string 

param bastionName string 

param publicIpName string 

resource vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'vmNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          subnet: {
            id: vmSubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: machineName
  location: location
  properties: {
    osProfile: {
      computerName: machineName
      adminUsername: machineUser
      linuxConfiguration: {
        ssh: {
          publicKeys: [
            {
              path: '/home/${machineUser}/.ssh/authorized_keys'
              keyData: vmKey
            }
          ]
        }
        disablePasswordAuthentication: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: bastionSubnetId
          }
        }
      }
    ]
  }
}


output publicIp string = publicIPAddress.id


