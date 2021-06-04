# AzureMarketplaceVmImageCreator

Example repository that uses GitHub Actions to produce Azure VM images for publishing to the Azure Marketplace using:

- Hashicorp Packer
- (Planned) Azure Image Builder

The images will be built in Azure and placed into an Azure Shared Image Gallery.

## Hashicorp Packer

The GitHub Actions workflow [build-packer-images.yml](.github\worklows\build-packer-images.yml) will build one or more virtual machine images. A job exists for each image that needs to be built by the workflow.

Before building the image the workflow will first create a [Shared Image Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) if it does not already exist.

Once the Shared Image Gallery has been created, the workflow will create an [Image Definition](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-images-portal#create-an-image-definition) using Bicep if it does not already exist for each image that is being built by the workflow. This is because Packer will not automatically create the Image Definition if it does not exist.

## Dependencies

### Shared Image Gallery

The Shared Image Gallery resource is created using some Bicep files that deploy a Resource Group and the Azure Image Gallery. The [main.bicep](bicep\main.bicep) file deploys the Resource Group and the [modules\imageGallery.bicep](bicep\modules\imageGallery.bicep).

### Image Definition

The Image Definition resource is created using a bicep file [modules\imageDefinition.bicep](bicep\modules\imageDefinition.bicep).
