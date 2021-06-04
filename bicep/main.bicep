targetScope = 'subscription'

param location string
param resourceGroupName string
param imageGalleryName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module imageGallery './modules/imageGallery.bicep' = {
  name: 'imageGallery'
  scope: rg
  params: {
    location: location
    imageGalleryName: imageGalleryName
  }
}
