resource "azurerm_network_security_group" "lab-nsg" {
  name                = "${var.resource_group_name}-${var.deployment_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow8081"
    description                = "Allow 8081"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow22"
    description                = "Allow SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "lab-vnet" {
  name                = "${var.resource_group_name}-${var.deployment_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "lab-subnet" {
  name                 = "${var.resource_group_name}-${var.deployment_prefix}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "lab-pip" {
  name                = "${var.resource_group_name}-${var.deployment_prefix}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "${var.resource_group_name}-${var.deployment_prefix}-vm"
}

resource "azurerm_network_interface" "lab-nic" {
  name                = "${var.resource_group_name}-${var.deployment_prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab-nic-nsg" {
  network_interface_id      = azurerm_network_interface.lab-nic.id
  network_security_group_id = azurerm_network_security_group.lab-nsg.id
}

resource "azurerm_virtual_machine" "lab-vm" {
  name                  = "${var.resource_group_name}-${var.deployment_prefix}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = ["${azurerm_network_interface.lab-nic.id}"]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "ubuntuVM-OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.resource_group_name}-${var.deployment_prefix}-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "lab-vm-ext" {
  name                 = "customscript"
  virtual_machine_id   = azurerm_virtual_machine.lab-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.script_file))}"
    }
    PROT
}

output "fqdn" {
  value = azurerm_public_ip.lab-pip.fqdn
}
