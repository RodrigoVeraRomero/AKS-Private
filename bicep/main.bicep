
/*PARAMS*/
param location string = deployment().location
param sopokeVnetName string = 'vnetSpoke'
param hubVnetName string = 'vnetHub'
param routeTableName string = 'routeTablervr'
param machineName string = 'jumboxUbunturvr'
param machineUser string = 'machineUser'

param vmKey string  = 'Miosa-.#Er334'
param bastionName string = 'bastionVMRVR'
param publicIpName string = 'publicBastionRVR'
param firewallName string = 'firewallRVR'
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

param logAnalyticsName string = 'logAnalyticsRVR'

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

module logAnalytic 'logAnalytics.bicep' = {
  name: 'logAnalytic'
  scope: resourceGroup(rg.name)
  params:{
    name: logAnalyticsName
    location:location
  }
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
  }
  dependsOn:[
    networking
    logAnalytic
  ]
}
