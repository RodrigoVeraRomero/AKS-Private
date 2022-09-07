param name string
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
  }
}

output logAnalyticsId string = logAnalytics.id 
