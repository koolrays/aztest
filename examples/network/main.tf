provider "azurerm" {
  version = "1.37.0"
}

#create resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.system}"
  location = var.location
  tags = {
    Environment = var.system
  }
}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev-${var.location}-${var.system}-001"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-dev-${var.location}-${var.system}-001 "
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet_prefix
}

# Create network security group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.system}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "sub_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}