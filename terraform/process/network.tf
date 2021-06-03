data "azurerm_virtual_network" "vnet" {
  name = "kthw-djm"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name = "k8s"
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}
