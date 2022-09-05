# Azure Arquitecture

This architecture is based on the AKS Baseline architecture that Microsoft's recommended as starting point for AKS infrastructure
https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks

## Networking
Hub-Spoke network is a topology that help us to organize our workloads, Hub like a unique point of connectivity to our workload that help to have the control for ingress and egress and spoke is a isolated network in which will be allocate the workload components. Spoke could be one or more network in the topology. In this exercise is proposed to have a hub and one spoke networking in spoke networking will contain an isolated AKS whit full configuration of Bonita 

### SPOKE VNET 
Virtual Network for AKS cluster (11.100.0.0/24)
* Subnet Privatelinks: For Azure Key Vault, Container Registry and Azure Disk
* Subnet Internal Load Balencer: For AKS-Managed Balancer

### HUB
Virtual Network for connectivity (11.140.0.0/16)
* Subnet Firewall: For outboud restrictions
* Subnet Bastion: For VM Connectivity
* Subnet VM: For VM to access to AKS

## AKS Access

For this architecture is defined Azure AD Managed identities the cluster will interact whit Azure Key vault to save secrets, Azure Container Registries to save and get images and to postgresql database to save the data of Bonita postgresql.
* Azure AD Managed identities

## AKS Ingress

The requirement is to have Bonita access in private mode no external user will have access to bonita an Load Balancer is the component have two modes internal and public IP, for our propose  private load balancer will be implemented
* Internal Load Balancer: Private IP

## Secret Management
Azure Key Vault is a cloud service for securely storing and accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, or cryptographic keys https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts 
This implementation need to save passwords for postgresql access in secure way using Azure Key Vault 
* Azure Key Vault

## Azure Files
For Bonita Postgres data is necessary to share and persist volumes in different nodes whit azure files is possible to have a storage account and a share file to have read and write access
https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv

## Private Link
Private Link is an azure component that enable the private access to paas components in this architecture need to have private access to key vault and azure files.

## VM
VM is a jumb box to private cluster for this workload is an access to cluster management and also to Bonita workload

## Diagram
<img src="https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Img/Arquitecture.jpg" width="385px" align="center">
