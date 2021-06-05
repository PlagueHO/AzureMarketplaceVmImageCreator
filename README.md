# AzureMarketplaceVmImageCreator

Example repository that uses GitHub Actions to produce Azure VM images for publishing to the Azure Marketplace using:

- Hashicorp Packer
- (Planned) Azure Image Builder

The images will be built in Azure and placed into an Azure Shared Image Gallery.

## Hashicorp Packer

[![build-packer-images](https://github.com/DsrDemoOrg/AzureMarketplaceVmImageCreator/actions/workflows/build-packer-images.yml/badge.svg)](https://github.com/DsrDemoOrg/AzureMarketplaceVmImageCreator/actions/workflows/build-packer-images.yml)

The GitHub Actions workflow [build-packer-images.yml](.github\worklows\build-packer-images.yml) will build one or more virtual machine images. A job exists for each image that needs to be built by the workflow.

Before building the image the workflow will first create a [Shared Image Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) if it does not already exist.

Once the Shared Image Gallery has been created, the workflow will create an [Image Definition](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-images-portal#create-an-image-definition) using Bicep if it does not already exist for each image that is being built by the workflow. This is because Packer will not automatically create the Image Definition if it does not exist.

> Note: The Packer actions will actually use the Azure connection that is set up by the AZ CLI actions (`azure/login@v1`) that execute to configure the dependent resources. This eliminates the need to pass in service principal details to the Packer commands.

## Azure Image Builder

This is not currently implemented but is planned.

## Workflow Variables

The workflows contains a number of variables at both the workflow and the job level. The workflow level apply to all images that are build by the workflow. The job level variables only relate to the specific image being built. If there are more than one image being built by the workflow, then there will be multiple copies of the variables.

### Workflow

- **LOCATION**: The Azure Location to build the images in and to deploy the shared image gallery resource.
- **DESTINATION_RESOURCE_GROUP_NAME**: The name of the resource group to put all the resources/images into.
- **DESTINATION_IMAGE_GALLERY_NAME**: The name of the shared image gallery.
- **DESTINATION_PUBLISHER**: The name of the publisher that will be used for all image definitions. Allowed characters are uppercase or lowercase letters, digits, hyphen(-), period (.), underscore (_). Names are not allowed to end with period(.). The length of the name cannot exceed 128 characters.
- **DESTINATION_IMAGE_VERSION**: The image definition version to use for all images created by the workflow. The run number is appended onto the end of the version to ensure it is unique.
- **AZURE_***: These variables should not be changed and pull the azure service principal information from the credential secret for use by packer.

### Job

- **PACKER_FILE**: The path to the packer file to use for building this image definition.
- **DESTINATION_IMAGE_NAME**: The image definition name to create. Must not contain spaces or symbols.
- **DESTINATION_IMAGE_DESCRIPTION**: The image definition description to create.
- **DESTINATION_OS_TYPE**: The OS of the image definition to create. Windows or Linux.
- **DESTINATION_SKU**: The sku for the image definition to create.
- **DESTINATION_OFFER**: The offer for the image definition to create.
- **SOURCE_IMAGE_PUBLISHER**: The publisher of the source image.
- **SOURCE_IMAGE_OFFER**: The offer from the publisher of the source image.
- **SOURCE_IMAGE_SKU**: The SKU for the source image.

## Dependencies

### Shared Image Gallery

The Shared Image Gallery resource is created using some Bicep files that deploy a Resource Group and the Azure Image Gallery. The [main.bicep](bicep\main.bicep) file deploys the Resource Group and the [modules\imageGallery.bicep](bicep\modules\imageGallery.bicep).

> Note: This could easily be created to Terraform if preferred.

### Image Definition

The Image Definition resource is created using a bicep file [modules\imageDefinition.bicep](bicep\modules\imageDefinition.bicep). This is checked every time an image definition is built
because if it does not exist before `Build Image Definition` job runs it will fail because
Packer requires that it does exist.

> Note: This could easily be created to Terraform if preferred.
