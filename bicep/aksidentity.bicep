param aksName string
param location string

resource aksidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${aksName}identity'
  location: location
}
output principalId string = aksidentity.properties.principalId
output id string = aksidentity.id
