#### Provision network resources
resource "azurerm_virtual_network" "vnet" {
  name                = "kthw-djm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet" {
  name = "k8s"
  address_prefixes = ["10.0.0.0/24"]
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_application_security_group" "nodes" {
  name                = "nodes"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    source = "Kubernetes-the-hard-way"
  }
}

resource "azurerm_network_security_group" "kthw" {
  name                = "kube-rg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_rule" "allowinternodein" {
  name = "allow-internode-comms"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_application_security_group_ids = [azurerm_application_security_group.nodes.id]
  destination_application_security_group_ids = [azurerm_application_security_group.nodes.id]
  resource_group_name = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.kthw.name
}

resource "azurerm_network_security_rule" "allowinternodeout" {
  name = "allow-internode-comms"
  priority = 100
  direction = "Outbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_application_security_group_ids = [azurerm_application_security_group.nodes.id]
  destination_application_security_group_ids = [azurerm_application_security_group.nodes.id]
  resource_group_name = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.kthw.name
}

resource "azurerm_network_security_rule" "allowmanagement" {
  name = "allow-management"
  priority = 200
  direction = "Inbound"
  access = "Allow"
  protocol = "*"
  resource_group_name = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.kthw.name
  source_port_range = "*"
  source_address_prefix = "0.0.0.0/0"
  destination_port_ranges = ["22", "6443"]
  destination_address_prefix = "10.0.0.0/16"
}

