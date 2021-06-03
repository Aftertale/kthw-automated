resource "azurerm_network_interface" "workernic" {
  name                = "node-nic-worker-${count.index}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  count = var.node_count

  ip_configuration {
    name                          = "internalw"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.2${count.index}"
  }
}

resource "azurerm_linux_virtual_machine" "workernode" {
  name                = "k8s-worker-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  count = var.node_count
  
  tags = {
    pod-cidr = "10.0.${count.index}.0/24"
  }

  network_interface_ids = [
    azurerm_network_interface.workernic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
