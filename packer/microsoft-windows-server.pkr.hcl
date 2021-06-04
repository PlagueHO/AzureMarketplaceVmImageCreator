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
   build_resource_group_name = "dsr-packer-rg"
   image_offer = "WindowsServer"
   image_publisher = "MicrosoftWindowsServer"
   image_sku = "2016-Datacenter"
   destination_resource_group_name = "dsr-imagegallery-rg"
   destination_image_gallery_name = "dsr-images-ig"
   vm_size = "Standard_D2_v2"
}

source "azure-arm" "microsoft-window-server" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  build_resource_group_name           = "${var.build_resource_group_name}"
  client_id                           = "${var.azure_client_id}"
  client_secret                       = "${var.azure_client_secret}"
  communicator                        = "winrm"
  image_offer                         = "${var.image_offer}"
  image_publisher                     = "${var.image_publisher}"
  image_sku                           = "${var.image_sku}"
  os_type                             = "Windows"
  shared_image_gallery_destination {
      subscription = "${var.azure_subscription_id}"
      resource_group = "${var.destination_resource_group_name}"
      gallery_name = "${var.destination_image_gallery_name}"
      image_name = "${var.image_name}"
      image_version = "${var.image_version}"
  }
  subscription_id                     = "${var.azure_subscription_id}"
  tenant_id                           = "${var.azure_tenant_id}"
  vm_size                             = "${var.vm_size}"
  winrm_insecure                      = true
  winrm_timeout                       = "5m"
  winrm_use_ssl                       = true
  winrm_username                      = "packer"
}

build {
  sources = ["source.azure-arm.microsoft-window-server"]

  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
      "choco install vscode -y"
      ]
  }
}
