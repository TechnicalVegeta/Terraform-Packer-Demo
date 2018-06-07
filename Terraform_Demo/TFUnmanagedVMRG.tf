# Configure the Azure Resource Manager Provider
provider "azurerm" {
subscription_id = " "  #subscription ID of azure you will be using
client_id = " " # mention the client id /user Name from azure service principal
client_secret = " "  #password generated /key of azure service principal
tenant_id = " " # Tenent ID from azure
version = "1.1"
}
provider "random" {
version = "~> 1.1"
}
variable "location" { default = "Central US" }
variable "username" { default = "username" }
variable "password" { default = "Password" }
variable "storage" { default = "tfstoreacc1"}
resource "azurerm_resource_group" "TFVMRG" {
name = "TerraformDemoRG"
location = "${var.location}"
}
resource "azurerm_virtual_network" "TFNetwork" {
name = "TFVMNetwork"
address_space = ["10.0.0.0/16"]
location = "${var.location}"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
}
resource "azurerm_subnet" "TFSubnet1" {
name = "TFVMSubnet1"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
virtual_network_name = "${azurerm_virtual_network.TFNetwork.name}"
address_prefix = "10.0.2.0/24"
}
resource "azurerm_network_interface" "TFNetworkInterface1" {
name = "TFVMNetworkInterface1"
location = "${var.location}"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
ip_configuration {
name = "tfVMConfiguration1"
subnet_id = "${azurerm_subnet.TFSubnet1.id}"
private_ip_address_allocation = "dynamic"
public_ip_address_id = "${azurerm_public_ip.TFPublicIp.id}"
}
}
resource "azurerm_public_ip" "TFPublicIp" {
name = "TFPublicIp"
location = "${var.location}"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
public_ip_address_allocation = "dynamic"
tags {
environment = "Terraform Demo"
}
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
keepers = {
# Generate a new ID only when a new resource group is defined
resource_group = "${azurerm_resource_group.TFVMRG.name}"
}
byte_length = 8
}

resource "azurerm_storage_account" "tfstorageaccount" {
name = "tfstoreacc2"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
location = "${var.location}"
account_tier = "Standard"
account_replication_type = "LRS"
#ignore_destroy = "true"
}
resource "azurerm_storage_container" "tfstoragecontainer" {
name = "images"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
storage_account_name = "${azurerm_storage_account.tfstorageaccount.name}"
container_access_type = "private"
}
resource "azurerm_virtual_machine" "TFVM1" {
name = "TFVM1"
location = "${var.location}"
resource_group_name = "${azurerm_resource_group.TFVMRG.name}"
network_interface_ids = ["${azurerm_network_interface.TFNetworkInterface1.id}"]
vm_size = "Standard_DS2_V2"

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true
# Uncomment this line to delete the data disks automatically when deleting the VM
delete_data_disks_on_termination = true
#commented because we are creating it from the Image_url
#storage_image_reference {
# publisher = "MicrosoftWindowsServer"
# offer = "WindowsServer"
# sku = "2016-Datacenter"
# version = "latest"
#}
storage_os_disk {
name = "TFosdisk1"
image_uri = "https://tfstoreacc1.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/PkrDemoImg-osDisk.71560976-9e35-41cf-8cb8-f7a4ab3f8006.vhd"
vhd_uri = "https://tfstoreacc1.blob.core.windows.net/${azurerm_storage_container.tfstoragecontainer.name}/TFosdisk1.vhd"
os_type = "Windows"
caching = "ReadWrite"
create_option = "FromImage"
}
os_profile {
computer_name = "TFTeamplayVM1"
admin_username = "${var.username}"
admin_password = "${var.password}"
}
os_profile_windows_config {
enable_automatic_upgrades = false
}
}