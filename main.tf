resource "azurerm_resource_group" "rgs" {
  name     = "Test-RG"
  location = "Central India"
}

resource "azurerm_virtual_network" "rgs" {
  name                = "Test-Vnet"
  resource_group_name = azurerm_resource_group.rgs.name
  location            = azurerm_resource_group.rgs.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_interface" "rgs" {
  name                = "Test-interface"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name


  ip_configuration {
    name                          = "Test-IP"
    subnet_id                     = azurerm_subnet.rgs.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.rgs.id
  }
}


resource "azurerm_subnet" "rgs" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.rgs.name
  virtual_network_name = azurerm_virtual_network.rgs.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "rgs" {
  name                = "TestPublicIp"
  resource_group_name = azurerm_resource_group.rgs.name
  location            = azurerm_resource_group.rgs.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_machine" "rgs" {
  name                  = "Test-VM"
  location              = azurerm_resource_group.rgs.location
  resource_group_name   = azurerm_resource_group.rgs.name
  network_interface_ids = [azurerm_network_interface.rgs.id]
  vm_size               = "Standard_B2as_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "Test-Vm"
    admin_username = "azureuser"
    admin_password = "Dayalpur@2026"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


resource "azurerm_network_security_group" "rgs" {
  name                = "Test-NSG"
  location            = azurerm_resource_group.rgs.location
  resource_group_name = azurerm_resource_group.rgs.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "rgs" {
  network_interface_id      = azurerm_network_interface.rgs.id
  network_security_group_id = azurerm_network_security_group.rgs.id
}



