
/*PARAMS*/
param location string = deployment().location
param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'
param routeTableName string = 'routeTablervr'
param machineName string = 'VM-Jumbox-RVR'
param machineUser string = 'machineUser'

param vmKey string  = 'Miosa-.#Er334'
param bastionName string = 'bastionVMRVR'
param publicIpName string = 'publicBastionRVR'
param firewallName string = 'firewallRVR'
param publicFirewallIpName string = 'firewallIPRVR'

param fileShareName string = 'dbfileshare'
param storageName string = 'storageaccountrvr'

param keyVaultName string = 'keyvaultRVR'


param secretPassword string = 'passwordpostgresql'
param passwordValue string = 'npKdammFd-.4?ds'


param privateKeyVaultName string = 'privatekeyvaultRVR'
param privateStorageName string = 'privatestorageRVR'

param logAnalyticsName string = 'logAnalyticsRVR'

param aksName string = 'privateAKS-RVR'
param kubernetesVersion string  = '1.23.8'
param dnsPrefix string = 'aks-dns'
param serviceCidr string = '10.0.0.0/16'
param dnsServiceIP string = '10.0.0.10'
param dockerBridgeCidr string = '172.17.0.1/16'

// USER ADMIN AKS CHANGE YOUR USER ID
param objectid string = ''
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
    routeTableName : routeTableName
  }
  dependsOn:[
    networking
    vmfinal
  ]
}


/****************************************************************************************************************************/
/********************************************************SPOKE COMPONENTS*****************************************************/
/****************************************************************************************************************************/
module aksidentity 'aksidentity.bicep'= {
  scope: resourceGroup(rg.name)
  name: 'aksidentity'
  params:{
    aksName:aksName
    location:location
  }
}
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
    secretPassword: secretPassword
    tenant: subscription().tenantId  
  }
  dependsOn:[
    storage
  ]
}

module privateEndponts 'privateEndpoints.bicep' = {
  name: 'privateendpoints'
  scope: resourceGroup(rg.name)
  params:{
    privateKeyVaultName : privateKeyVaultName
    privateStorageName : privateStorageName
    location : location
    subnetId : networking.outputs.vnetSpoke.properties.subnets[1].Id
    vnetSpokeId : networking.outputs.spokeId
    vnetHubId : networking.outputs.vnetHubId
    keyVaultId: keyV.outputs.keyvaultId 
    storageId : storage.outputs.storageAccountID
  }
  dependsOn:[
    networking
    storage
    keyV
  ]
}

module logAnalytic 'logAnalytics.bicep' = {
  name: 'logAnalytic'
  scope: resourceGroup(rg.name)
  params:{
    name: logAnalyticsName
    location:location
  }
}



module aksroleassign 'roleassigments.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksroleassign'
  params:{
    principalId: aksidentity.outputs.principalId
  }
 dependsOn:[
  aksidentity
  firewall
 ]
}

module aks 'aks.bicep'={
  name: 'aks'
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
    logAnalyticsID: logAnalytic.outputs.logAnalyticsId
    vnetHubId: networking.outputs.vnetHubId
    vnetSpokeId: networking.outputs.vnetSpokeId
    identityId : aksidentity.outputs.id
    objectid: objectid
    
  }
  dependsOn:[
    networking
    logAnalytic
    aksidentity
    aksroleassign
  ]
}


