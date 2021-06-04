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
variable "location" {
  type = string
}
variable "destination_resource_group_name" {
  type = string
}
variable "destination_image_gallery_name" {
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
   vm_size = "Standard_D2_v2"
}

locals {
  managed_image_name = "${concat(var.image_name, replace(var.image_version,'.','-'))}"
}

source "azure-arm" "microsoft-windows-server" {
  azure_tags = {
    dept = "Demonstration"
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
      replication_regions = [ "${var.location}" ]
  }
  managed_image_name                  = "${local.managed_image_name}"
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
