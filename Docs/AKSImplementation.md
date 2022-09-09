# AKS Implementation

Once we have the infrastructure created with bicep [Architecture Implementation](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AzureArchitectureImplementation.md "Architecture Implementation") will proceed to configure the "Jump Box" virtual machine and execute the yamls within AKS for the application deployment.

## Jumbox Components Installation

* Use bastion to log into Jumbox.
* Install [Azure CLI](https://aka.ms/installazurecliwindows "Azure CLI")
* Install [Chocolatey](https://chocolatey.org/install?ref=hackernoon.com "Chocolatey") running the following command into Power Shell Admin Instance
```powershell  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
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

* Connection to azure file needs storage account key, run the following commands to get it and add to kubernetes secrets.
```powershell  
$AKS_STORAGE_ACCOUNT_NAME = 'STORAGE NAME'
az storage account keys list -g $RESOURCE_GROUP -n $AKS_STORAGE_ACCOUNT_NAME
```
* Paste the command output into the next variable and run a command.
```powershell  
$STORAGE_KEY = 'OUTPUT KEY'
kubectl create namespace application
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$AKS_STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY -n application
```
* Download YAMl files from this repository and copy into jumbox machine to create the application.
* Edit azureprovider.yaml and set userAssignedIdentityID value whit the output of the following command
```powershell 
az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
```
* Run the following commands.
```powershell 
kubectl apply -f azureprovider.yaml -n application
kubectl apply -f postgresql-dep-svc.yam -n application
kubectl apply -f bonita-dep-svc.yam -n application
```
* Validate all pods are in running state.
```powershell 
kubectl get pods -n application
```
* Get service ip and test the application into jumbox copying external ip in explorer.
```powershell 
kubectl get svc -n application -o wide
```
* Clean environment
```powershell 
az group delete --name $RESOURCE_GROUP
```
