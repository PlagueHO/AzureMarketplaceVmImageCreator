param location string
param imageGalleryName string

resource imageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: imageGalleryName
  location: location
}
