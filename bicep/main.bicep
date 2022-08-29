
/*PARAMS*/


param location string = deployment().location


param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'


param machineName string = 'jumboxUbunturvr'
param machineUser string = 'machineUser'

param vmKey string  = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDONgnDaI3vUbguZ8WsAOei0G3qPi0db34wn5stHasaIgldi2629MFIqsHMYsjVV92ZkLXwnIX4YQlgjt9bry1b3X1793NRwT5v9JiRkuecV3s8I4JltRYH/x3eaRkFNrIS3hPPsh9lVeY3dZAlrwGcQN4TglOCIpXSLux+v23t/mbMmCFK2cj+/nsVuwYfjDoVo6kpWSbtkPR2wqy/I7NQfd+Gsik3KuX8T0zITEmW+YuiIxNmKI3yfYfzj/OMwNKCDkBdac57lTWBQloGb6HPFFwmNwQV7DwHf8Hlv/8SHZXeoD2bXn9z9hYtKjp2PwrfWdi0WV7ERaemQ8pQRoIVxSM9PaYk09IOAxBo5I3iUOyPMm49smFXCmX9103TucICxCi1Scnr5x1UYF410qcsVophg1fw989v8KXTnLvAmMj8OJ0Pl3s7Jl1kGBy0BqPmPFJZCVQWBuX+Xgn403VmnNsZsoHG3bhdszWMBx48GL75FZzguoBjq/N+0nqe0iTJrTI9eT0zf4ZInNuXmwIUJvkmmB8jnK/nJgPjYFfkhIo9aR6zNGEio7YvRiFrD2f0Id3FW8/ldCLwQJzQY9KPC04uFQsaQyUapbljsvaKPhENpLFnwrsrAq+yuGtn572F7AL2pVG6n8slFoVHH/XAApHsIqMGHvSkgM3NaGFb9w== testaks'

param bastionName string = 'bastionVMRVR'
param publicIpName string = 'publicBastionRVR'

targetScope = 'subscription'

/*RESOURCE GROUP*/

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  location: location
  name: 'pruebaAKSprivate'
}

/*NETWORKING*/

module networking '../bicep/network.bicep' = {
  name: 'networking'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    sopokeVnetName: sopokeVnetName
    hubVnetName : hubVnetName
  }

}
/*VIRTUAL MACHINE*/
module vmfinal '../bicep/vm.bicep' = {
  name: 'vmfinal'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    machineName : machineName
    publicIpName: publicIpName
    machineUser: machineUser
    vmKey: vmKey
    bastionName : bastionName
    bastionSubnetId: networking.outputs.vnetSpoke.properties.subnets[2].Id
    vmSubnetId: networking.outputs.vnetSpoke.properties.subnets[1].Id
  }
  dependsOn:[
    networking
  ]
}
