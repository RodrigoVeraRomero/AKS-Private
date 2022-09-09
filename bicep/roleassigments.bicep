param principalId string


resource aksRoleAssigmentNetwork 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
 
  name: guid(subscription().id, 'principalIdNetwork')
  properties: {
    
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
  }
}

resource aksRoleAssigmentZone 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, '${principalId}Zone')
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b12aa53e-6015-4669-85d0-8515ebb3ae7f')
  }
}




