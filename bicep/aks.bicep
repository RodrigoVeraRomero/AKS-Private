
param aksName string
param location string 
param kubernetesVersion string 
param dnsPrefix string
param subnetId string
param serviceCidr string
param dnsServiceIP string
param dockerBridgeCidr string
param logAnalyticsID string
param vnetSpokeId string
param vnetHubId string
param identityId string
param objectid string

var roleIdMapping = {
  'Azure Kubernetes Service RBAC Cluster Admin': 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
}
var roleName = 'Azure Kubernetes Service RBAC Cluster Admin'


resource privateZoneAKS 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${location}.azmk8s.io'
  location: 'global'
  properties: {}
  
}

resource privateDnsZoneLinkAKSSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneAKS
  name: 'spoke-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetSpokeId
    }
  }
}


resource privateDnsZoneLinkAKSHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZoneAKS
  name: 'hub-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetHubId
    }
  }
}

resource aksresource 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  location: location
  name: aksName
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 2
        enableAutoScaling: false
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: null
        nodeTaints: []
        enableNodePublicIP: false
        tags: {
        }
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }
    disableLocalAccounts: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: privateZoneAKS.id
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
      azurepolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsID
        }
        enabled: true
      }
    }
  }
  tags: {
  }
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities:  {
      '${identityId}' : {}
    }
  }
}

resource aksRoleAsigmentUser 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleIdMapping[roleName],objectid,aksresource.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdMapping[roleName])
    principalId: objectid
    principalType: 'User'
  }
}

resource aksRoleAssigmentKV 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id,'${aksresource.id}keyvault')
  properties: {
    principalId: aksresource.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  }
}

