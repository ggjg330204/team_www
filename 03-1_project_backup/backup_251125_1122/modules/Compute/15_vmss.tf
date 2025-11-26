#source\15_vmss
resource "azurerm_linux_virtual_machine_scale_set" "www_vmss" {
    name = "${var.teamuser}-vmss"
    resource_group_name = azurerm_resource_group.www_rg.name
    location = var.loca

    instances = 1
    #초기 인스턴스 수
    sku = "Standard_B2s"
    upgrade_mode = "Manual"
    source_image_id = azurerm_shared_image_version.www_version.id
    admin_username = "www"

    plan {
        publisher = "resf"
        product = "rockylinux-x86_64"
        name = "9-lvm"
    }
    admin_ssh_key {
        username = "www"
        public_key = file("./id_ed25519.pub.txt")
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "StandardSSD_LRS"
    }
    # setting nic&backendpool
    network_interface {
      name = "${var.teamuser}-vmss-nic"
      primary = true
      #network_security_group_id = azurerm_network_security_group.www_nsg_httpd.id
 
  ip_configuration {
    name                          = "${var.teamuser}-vmss-nic"
    subnet_id                     = azurerm_subnet.www_vmss.id
    #load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.www_back.id]
    application_gateway_backend_address_pool_ids = [for p in azurerm_application_gateway.www_appgw.backend_address_pool : p.id]
  }
    }
  boot_diagnostics {
    storage_account_uri = null
  }
  depends_on = [ azurerm_shared_image_version.www_version ]
}
    

