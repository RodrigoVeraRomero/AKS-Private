
/*PARAMS*/
param location string = deployment().location
param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'
param routeTableName string = 'routeTablervr'
param machineName string = 'jumboxUbunturvr'
param machineUser string = 'machineUser'

param vmKey string  = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDONgnDaI3vUbguZ8WsAOei0G3qPi0db34wn5stHasaIgldi2629MFIqsHMYsjVV92ZkLXwnIX4YQlgjt9bry1b3X1793NRwT5v9JiRkuecV3s8I4JltRYH/x3eaRkFNrIS3hPPsh9lVeY3dZAlrwGcQN4TglOCIpXSLux+v23t/mbMmCFK2cj+/nsVuwYfjDoVo6kpWSbtkPR2wqy/I7NQfd+Gsik3KuX8T0zITEmW+YuiIxNmKI3yfYfzj/OMwNKCDkBdac57lTWBQloGb6HPFFwmNwQV7DwHf8Hlv/8SHZXeoD2bXn9z9hYtKjp2PwrfWdi0WV7ERaemQ8pQRoIVxSM9PaYk09IOAxBo5I3iUOyPMm49smFXCmX9103TucICxCi1Scnr5x1UYF410qcsVophg1fw989v8KXTnLvAmMj8OJ0Pl3s7Jl1kGBy0BqPmPFJZCVQWBuX+Xgn403VmnNsZsoHG3bhdszWMBx48GL75FZzguoBjq/N+0nqe0iTJrTI9eT0zf4ZInNuXmwIUJvkmmB8jnK/nJgPjYFfkhIo9aR6zNGEio7YvRiFrD2f0Id3FW8/ldCLwQJzQY9KPC04uFQsaQyUapbljsvaKPhENpLFnwrsrAq+yuGtn572F7AL2pVG6n8slFoVHH/XAApHsIqMGHvSkgM3NaGFb9w== testaks'
param bastionName string = 'bastionVMRVR'
param publicIpName string = 'publicBastionRVR'
param firewallName string = 'firewallName'
param publicFirewallIpName string = 'firewallIPRVR'

param fileShareName string = 'dbfileshare'
param storageName string = 'storageaccountrvr'

param keyVaultName string = 'keyvaultRVR'


param secretPassword string = 'PasswordPostgress'
param passwordValue string = 'npKdammFd-.4?ds'
param secretUser  string = 'userpostgress'
param userValue string = 'AdminPostgress'

param privateKeyVaultName string = 'privatekeyvaultRVR'
param privateStorageName string = 'privatestorageRVR'

param aksName string = 'privateAKS-RVR'
param kubernetesVersion string  = '1.23.8'
param dnsPrefix string = 'aks-dns'
param serviceCidr string = '10.0.0.0/16'
param dnsServiceIP string = '10.0.0.10'
param dockerBridgeCidr string = '172.17.0.1/16'


targetScope = 'subscription'

/*RESOURCE GROUP*/

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  location: location
  name: 'AKSprivate'
}
/*NETWORKING*/

module networking '../bicep/network.bicep' = {
  name: 'networking'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    sopokeVnetName: sopokeVnetName
    hubVnetName : hubVnetName
    routeTableName : routeTableName
  }

}
/****************************************************************************************************************************/
/********************************************************HUB COMPONENTS******************************************************/
/****************************************************************************************************************************/


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
    bastionSubnetId: networking.outputs.vnetHub.properties.subnets[2].Id
    vmSubnetId: networking.outputs.vnetHub.properties.subnets[1].Id
    nsg: networking.outputs.nsg
  }
  dependsOn:[
    networking
  ]
}

module firewall 'firewall.bicep' = {
  name: 'firewall'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    firewallName : firewallName
    subnetfirewall : networking.outputs.vnetHub.properties.subnets[0].Id
    publicFirewallIpName: publicFirewallIpName
  }
  dependsOn:[
    networking
    vmfinal
  ]
}


/****************************************************************************************************************************/
/********************************************************SPOKE COMPONENTS*****************************************************/
/****************************************************************************************************************************/
module storage 'storage.bicep' ={
   name:'storage'
   scope:resourceGroup(rg.name)
   params: {
     fileShareName: fileShareName
     location:location
     storageName: storageName
   }
}

module keyV 'keyvault.bicep' ={
  name: 'keyV'
  scope: resourceGroup(rg.name)
  params:{
    keyVaultName: keyVaultName
    location: location
    passwordValue: passwordValue
    userValue: userValue

    secretPassword: secretPassword
    secretUser: secretUser
    tenant: subscription().tenantId  
  }
}

module privateEndponts 'privateEndpoints.bicep' = {
  name: 'privateendpoints'
  scope: resourceGroup(rg.name)
  params:{
    privateKeyVaultName : privateKeyVaultName
    privateStorageName : privateStorageName
    location : location
    subnetId : networking.outputs.vnetSpoke.properties.subnets[1].Id
    vnetId : networking.outputs.spokeId
    keyVaultId: keyV.outputs.keyvaultId 
    storageId : storage.outputs.storageAccountID
  }
  dependsOn:[
    networking
    storage
    keyV
  ]
}

module aks 'aks.bicep'={
  name: 'aksrvr'
  scope: resourceGroup(rg.name)
  params:{
    aksName : aksName
    location : location
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    subnetId : networking.outputs.vnetSpoke.properties.subnets[0].Id
    serviceCidr : serviceCidr
    dnsServiceIP: dnsServiceIP
    dockerBridgeCidr : dockerBridgeCidr
  }
  dependsOn:[
    networking
  ]
}
