provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.training}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-${var.training}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal_ip" {
  name                 = "${var.prefix}-${var.training}-subnet-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-${var.training}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.username}-${var.training}-${var.prefix}"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-${var.training}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}--${var.training}-internal_ip"
    subnet_id                     = azurerm_subnet.internal_ip.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "random_password" "password" {
  length = 16
  special = true
  lower = true
  upper = true
  min_upper = 3
  min_lower = 3
  min_special = 3
  min_numeric = 3
  override_special = "_%@$*"
}

data "template_file" "cloud_init" {
  template = "${file("${path.module}/custom-data.sh.tpl")}"
  vars = {
    username = var.username
    password = random_password.password.result
    training = var.training
    fullname = var.full_name
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-${var.training}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = random_password.password.result
  custom_data                     = base64encode(data.template_file.cloud_init.rendered)
  disable_password_authentication = false
  # disable_password_authentication = true
  network_interface_ids           = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"
    disk_size_gb         = 30
  }
}

output "server_name" {
  value = "${var.username}-${var.training}-${var.prefix}.${var.location}.cloudapp.azure.com"
}

output "service_name" {
  value = "http://${var.username}-${var.training}-${var.prefix}.${var.location}.cloudapp.azure.com:8081/"
}

output "credentials" {
  value = "${var.username} / ${random_password.password.result}"
}
