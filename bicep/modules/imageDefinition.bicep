param location string
param imageGalleryName string
param imageDefinitionName string
param imageDescription string
param offer string
param publisher string
param sku string

@allowed([
  'Windows'
  'Linux'
])
param osType string

resource imageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: imageGalleryName
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: imageGallery
  name: imageDefinitionName
  location: location
  properties: {
    description: imageDescription
    identifier: {
      offer: offer
      publisher: publisher
      sku: sku
    }
    osState: 'Generalized'
    osType: osType
    hyperVGeneration: 'V1'
  }
}
