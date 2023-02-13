param uniqueName string = 'leorecognme'
@description('Location for all resources.')
param location string = resourceGroup().location

param createdBy string = 'Leo Leung'
param projectName string = 'Azure Trial'
param dateTime string = utcNow()

module cogncv './modules/cognservice.bicep' = {
  name: 'cognitive-service-example'
  params: {
    uniqueName: uniqueName
    location: location
    createdBy: createdBy
    projectName: projectName
    dateTime: dateTime
  }
}
