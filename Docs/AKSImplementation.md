# AKS Implementation

Once we have the infrastructure created with bicep [Architecture Implementation](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AzureArchitectureImplementation.md "Architecture Implementation") will proceed to configure the "Jump Box" virtual machine and execute the yamls within AKS for the application deployment.

## Jumbox Components Installation

* Use bastion to log into Jumbox.
* Install [Azure CLI](https://aka.ms/installazurecliwindows "Azure CLI")
* Install [Chocolatey](https://aka.ms/installazurecliwindows "Chocolatey") running the following command into Power Shell Admin Instance
```powershell  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(‘https://chocolatey.org/install.ps1’))
```
* Install Kubectl
```powershell  
choco install kubernetes-cli
```
## Connect AKS Cluster
* Run the following script to get credentials from Azure Cluster
```powershell  
$SUBCRIPTION = 'YOUR SUBSCRIPTION ID'
$RESOURCE_GROUP= 'YOUR CLUSTER RESOURCE GROUP'
$AKS_CLUSTER_NAME= 'YOUR CLUSTER NAME'
az login
az account set --subscription $SUBCRIPTION
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME
```
* Test your connection using this command
```powershell  
kubectl get no
```
* if not get results sing in again using https://microsoft.com/devicelogin and the code in output Power Shell

## Implement Application
