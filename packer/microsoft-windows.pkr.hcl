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
variable "destination_image_name" {
  type = string
}
variable "destination_image_version" {
  type = string
}
variable "source_image_publisher" {
  type = string
}
variable "source_image_offer" {
   type = string
}
variable "source_image_sku" {
  type = string
}

variables {
   vm_size = "Standard_D4_v4"
}

locals {
  managed_image_name = "${var.destination_image_name}-${replace(var.destination_image_version, "." ,"-")}"
}

source "azure-arm" "microsoft-windows" {
  azure_tags = {
    dept = "Demonstration"
  }
  communicator                        = "winrm"
  client_id                           = "${var.azure_client_id}"
  client_secret                       = "${var.azure_client_secret}"
  image_offer                         = "${var.source_image_offer}"
  image_publisher                     = "${var.source_image_publisher}"
  image_sku                           = "${var.source_image_sku}"
  location                            = "${var.location}"
  os_type                             = "Windows"
  shared_image_gallery_destination {
      subscription = "${var.azure_subscription_id}"
      resource_group = "${var.destination_resource_group_name}"
      gallery_name = "${var.destination_image_gallery_name}"
      image_name = "${var.destination_image_name}"
      image_version = "${var.destination_image_version}"
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
  sources = ["source.azure-arm.microsoft-windows"]

  provisioner "powershell" {
    inline = [
      "# Install Visual Studio Code",
      "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
      "choco install vscode -y",

      "# NOTE: the following *3* lines are only needed if the you have installed the Guest Agent.",
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureTelemetryService).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",

      "# Generalize the OS",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
