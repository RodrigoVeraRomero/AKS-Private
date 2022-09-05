# Azure Arquitecture


## SPOKE VNET 
Virtual Network for AKS cluster (10.200.0.0/24)
* Subnet Privatelinks: For Azure Key Vault, Container Registry and Azure Disk
* Subnet Internal Load Balencer: For AKS-Managed Balancer

## HUB
Virtual Network for connectivity (10.240.0.0/16)
* Subnet Firewall: For outboud restrictions
* Subnet Bastion: For VM Connectivity
* Subnet VM: For VM to access to AKS

## AKS Access
* Azure AD Managed identities

## AKS INGRESS
* Internal Load Balancer: Private IP
* Ingress Controller: Traefik

## Secret Management
* Azure Key Vault

## Policy Management
* Restricted + ACR, Key Vault, Azure Disk

## Node Scalability
* Automatic

## Pod Scalability
* Horizontal Pod Autoscaler HPA

## Monitor
* Liveness and Readiness probes
* Azure Monitor
* Prometheus
* Grafana 

## Cluster Operation
* IAC Github Actions
* Workload CI/CD Github Actions

## Workload Deployment strategies
* Blue-geen deployment

## Availability zone
* No required

<img src="https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Img/Arquitecture.jpg" width="385px" align="center">
