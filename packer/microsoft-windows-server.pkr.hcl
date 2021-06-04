variable "azure_subscription_id" {
  type = string
}
variable "azure_tenant_id" {
  type = string
}
variable "azure_client_id" {
  type = string
}
variable "azure_client_secret" {
  type = string
}
variable "image_name" {
  type = string
}
variable "image_version" {
  type = string
}

variables {
   image_offer = "WindowsServer"
   image_publisher = "MicrosoftWindowsServer"
   image_sku = "2016-Datacenter"
   destination_resource_group_name = "dsr-images-rg"
   destination_image_gallery_name = "dsrimagegallery"
   vm_size = "Standard_D2_v2"
   location = "East US"
   destination_image_gallery_region = "East US"
}

source "azure-arm" "microsoft-windows-server" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                           = "${var.azure_client_id}"
  client_secret                       = "${var.azure_client_secret}"
  communicator                        = "winrm"
  image_offer                         = "${var.image_offer}"
  image_publisher                     = "${var.image_publisher}"
  image_sku                           = "${var.image_sku}"
  location                            = "${var.location}"
  os_type                             = "Windows"
  shared_image_gallery_destination {
      subscription = "${var.azure_subscription_id}"
      resource_group = "${var.destination_resource_group_name}"
      gallery_name = "${var.destination_image_gallery_name}"
      image_name = "${var.image_name}"
      image_version = "${var.image_version}"
      replication_regions = [ "${var.destination_image_gallery_region}" ]
  }
  managed_image_name                  = "${var.image_name}"
  managed_image_resource_group_name   = "${var.destination_resource_group_name}"
  subscription_id                     = "${var.azure_subscription_id}"
  tenant_id                           = "${var.azure_tenant_id}"
  vm_size                             = "${var.vm_size}"
  winrm_insecure                      = true
  winrm_timeout                       = "5m"
  winrm_use_ssl                       = true
  winrm_username                      = "packer"
}

build {
  sources = ["source.azure-arm.microsoft-windows-server"]

  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
      "choco install vscode -y"
      ]
  }
}
