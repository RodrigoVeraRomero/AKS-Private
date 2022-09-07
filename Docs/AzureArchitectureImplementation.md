# Azure Architecture Implementation

This architecture is implemented using biceps that is a domain-specific language that uses declarative syntaxis to deploy Azure Resources. 

* [Arquitecture](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AzureArquitecture.md "Architecture")

* [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep "Bicep")


## Biceps Files

All biceps’ files are under the repository and the folder is bicep, in this folder are all the files necessary to deploy into azure a complete infrastructure of a base line private AKS as show in Architecture documentation.

# main.bicep
It's the main file to have all parameters and module definitions.

# network.bicep
This module create hub and spoke network and the peering between networks.

# vm.bicep
This module creates Windows 2019 virtual machine that is a jumbox to aks and bastion. Azure Bastion provides a secure remote connection from the Azure portal to Azure virtual machines (VMs) over Transport Layer Security (TLS). Provision Azure Bastion to the same Azure virtual network as your VMs or to a peered virtual network. Then connect to any VM on that virtual network or a peered virtual network directly from the Azure portal. [Bastion](https://docs.microsoft.com/en-us/training/modules/connect-vm-with-azure-bastion/2-what-is-azure-bastion "Bastion")


# firewall.bicep
This module creates a firewall whit AKS rule, this is a security component that allow have a control egress endpoints to AKS. [Firewall](https://docs.microsoft.com/en-us/azure/firewall/overview "Firewall")

# storage.bicep
This module creates a azure storage account and a file share this component save persistent data from Azure AKS aplication
https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview

# keyvault.bicep
This module creates a key vault this component save all secreted used by AKS. [Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/ "Key Vault")


# privateEndpoints.bicep
This module create a private endpoints for azure file and key vault these components create a private ip that help internal communication between AKS and components. [Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview "Private Endpoint")


# logAnalitycs.bicep
Create a log analytics workspace, this component is for monitoring propose and have metric information of cluster infrastructure and containers. [Log Analytics](https://docs.microsoft.com/en-us/azure/automation/ "Log Analytics")


# aks.biceps
This module creates a private aks. [AKS](https://docs.microsoft.com/es-mx/azure/aks/ "AKS")


## Bicep Implementation

# Requirements

* [Azure Account](https://azure.microsoft.com/en-us/free/search/?ef_id=Cj0KCQjwguGYBhDRARIsAHgRm4_WKFwwiujWSBLpK_kNgb9Sxq6JaIzWDmXmnpVbXXWfzxOdbUVfeuEaAlgMEALw_wcB%3AG%3As&OCID=AIDcmmxotgtm93_SEM_Cj0KCQjwguGYBhDRARIsAHgRm4_WKFwwiujWSBLpK_kNgb9Sxq6JaIzWDmXmnpVbXXWfzxOdbUVfeuEaAlgMEALw_wcB%3AG%3As&gclid=Cj0KCQjwguGYBhDRARIsAHgRm4_WKFwwiujWSBLpK_kNgb9Sxq6JaIzWDmXmnpVbXXWfzxOdbUVfeuEaAlgMEALw_wcB "Azure Account")

* [Azure Cli]( https://docs.microsoft.com/en-us/cli/azure/install-azure-cli "Azure Cli")  

# Create infrastructure

* Go to Bicep folder, in main.bicep change parameter resources names as your preference
* Run following script
```powershell  

$SUBCRIPTION = 'YOUR SUBSCRIPTION ID'
az login
az account set --subscription $SUBCRIPTION
az deployment sub create --location eastus2 --template-file main.bicep
```
