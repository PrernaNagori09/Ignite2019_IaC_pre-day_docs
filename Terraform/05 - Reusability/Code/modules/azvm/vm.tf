# Data source reference to key vault instance
data "azurerm_key_vault" "tf_pre-day" {
  name                = var.key_vault
  resource_group_name = var.rg
}

# Data source reference to the secret
data "azurerm_key_vault_secret" "tf_pre-day" {
  name         = var.secret_id
  key_vault_id = data.azurerm_key_vault.tf_pre-day.id
}

# Configure Virtual Machine
resource "azurerm_virtual_machine" "predayvm" {
  name                  = var.host_name
  location              = var.location
  resource_group_name   = var.rg
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.predaynic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1-${var.host_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.host_name
    admin_username = "testadmin"
    admin_password = data.azurerm_key_vault_secret.tf_pre-day.value
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags                = var.tags
}
