
param aksName string
param location string 
param kubernetesVersion string 
param dnsPrefix string
param subnetId string
param serviceCidr string
param dnsServiceIP string
param dockerBridgeCidr string
param logAnalyticsID string

resource resourceName_resource 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
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
    type: 'SystemAssigned'
  }
}
