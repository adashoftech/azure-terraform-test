terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "adot-rg" {
  name = "adot-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "adot_hub_poc" {
  name = "adot-hub-poc-vnet"
  resource_group_name = "adot-rg"
  location = "eastus"
  address_space = [var.hub_cidr]

  subnet {
    name = "hub_subnet_a"
    address_prefix = var.hub_subnet["a"]
  }

  subnet {
    name = "hub_subnet_b"
    address_prefix = var.hub_subnet["b"]
  }
}

resource "azurerm_virtual_network" "adot_spoke_poc" {
  name = "adot-spoke-poc-vnet"
  resource_group_name = "adot-rg"
  location = "eastus"
  address_space = [var.spoke_cidr]

  subnet {
    name = "spoke_subnet_a"
    address_prefix = var.spoke_subnet["a"]
  }

  subnet {
    name = "spoke_subnet_b"
    address_prefix = var.spoke_subnet["b"]
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peer" {
  name = "hub_to_spoke_peer"
  resource_group_name = azurerm_resource_group.adot-rg.name
  virtual_network_name = azurerm_virtual_network.adot_hub_poc.name
  remote_virtual_network_id = azurerm_virtual_network.adot_spoke_poc.id
  allow_virtual_network_access = true
}
resource "azurerm_virtual_network_peering" "spoke_to_hub_peer" {
  name = "spoke_to_hub_peer"
  resource_group_name = azurerm_resource_group.adot-rg.name
  virtual_network_name = azurerm_virtual_network.adot_spoke_poc.name
  remote_virtual_network_id = azurerm_virtual_network.adot_hub_poc.id
  allow_virtual_network_access = true
}

# Create VM Resources
resource "azurerm_windows_virtual_machine" "windows_vm01" {
  name                  = "windows_vm01"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location = azurerm_resource_group.adot-rg.location
  resource_group_name = azurerm_resource_group.adot-rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
 }
}