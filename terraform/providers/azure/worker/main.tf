variable "instance_type" {}
variable "image" {}
variable "count" {}
variable "wscount" {}
variable "cluster_name" {}

variable "os_admin_user" {}
variable "os_adm_passwd" {}
variable "ssh_public_key_file" {}

variable "tag_environment" {}
variable "tag_activity" {}

variable "region" {}
variable "rg_name" {}

variable "subnet_id" {}
variable "worker_sg_id" {}

#variable "web-lb_bp-id" {}
#variable "web_sg_id" {}

# worker nodes

resource "azurerm_availability_set" "worker" {
  name                = "workerAvailabilitySet"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"
  managed             = "true"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_public_ip" "worker" {
  name                         = "${var.cluster_name}-worker-pip-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"
  count                        = "${var.count}"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_network_interface" "worker" {
  name                      = "${var.cluster_name}-worker-ni-${count.index}"
  location                  = "${var.region}"
  resource_group_name       = "${var.rg_name}"
  network_security_group_id = "${var.worker_sg_id}"
  count                     = "${var.count}"

  ip_configuration {
    name                          = "${var.cluster_name}-worker-ip-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.worker.*.id, count.index)}"
  }
}

#resource "azurerm_network_interface" "worker-lb" {
#  name                      = "${var.cluster_name}-worker-lb-ni-${count.index}"
#  location                  = "${var.region}"
#  resource_group_name       = "${var.rg_name}"
#  network_security_group_id = "${var.web_sg_id}"
#  count                     = "${var.count}"
#
#  ip_configuration {
#    name                          = "${var.cluster_name}-worker-lb-ip-${count.index}"
#    subnet_id                     = "${var.subnet_id}"
#    private_ip_address_allocation = "dynamic"
#    load_balancer_backend_address_pools_ids = ["${var.web-lb_bp-id}"]
#    #load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_rule.winrm_nat.*.id, count.index)}"]
#  }
#}

# ********************************************************************************************************************************************************************
# ********************************************************************************************************************************************************************

resource "azurerm_virtual_machine" "worker" {
  name                  = "${var.cluster_name}-lworker-${count.index}"
  location              = "${var.region}"
  resource_group_name   = "${var.rg_name}"
  #network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}", "${element(azurerm_network_interface.worker-lb.*.id, count.index)}"]
  network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}"]
  primary_network_interface_id = "${element(azurerm_network_interface.worker.*.id, count.index)}"
  vm_size               = "${var.instance_type}"
  availability_set_id   = "${azurerm_availability_set.worker.id}"
  depends_on            = ["azurerm_availability_set.worker"]
  count                 = "${var.count}"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "${var.image}"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-worker-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-lw-${count.index}"
    admin_username = "${var.os_admin_user}"
    admin_password = "${var.os_adm_passwd}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.os_admin_user}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_public_key_file}")}"
    }
  }

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

# ********************************************************************************************************************************************************************
# Windows Server Worker
# ********************************************************************************************************************************************************************

resource "azurerm_public_ip" "wsworker" {
  name                         = "${var.cluster_name}-wsworker-pip-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"
  count                        = "${var.wscount}"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_network_interface" "wsworker" {
  name                      = "${var.cluster_name}-wsworker-ni-${count.index}"
  location                  = "${var.region}"
  resource_group_name       = "${var.rg_name}"
  network_security_group_id = "${var.worker_sg_id}"
  count                     = "${var.wscount}"

  ip_configuration {
    name                          = "${var.cluster_name}-wsworker-ip-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.wsworker.*.id, count.index)}"
  }
}


resource "azurerm_virtual_machine" "wsworker" {
  # Windows computer name cannot be more than 15 characters long
  name                  = "${var.cluster_name}-wsworker-${count.index}"
  #name                  = "ak-wsw-${count.index}"
  location              = "${var.region}"
  resource_group_name   = "${var.rg_name}"
  #network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}", "${element(azurerm_network_interface.worker-lb.*.id, count.index)}"]
  network_interface_ids = ["${element(azurerm_network_interface.wsworker.*.id, count.index)}"]
  primary_network_interface_id = "${element(azurerm_network_interface.wsworker.*.id, count.index)}"
  vm_size               = "${var.instance_type}"
  availability_set_id   = "${azurerm_availability_set.worker.id}"
  depends_on            = ["azurerm_availability_set.worker"]
  count               = "${var.wscount}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServerSemiAnnual"
    sku       = "Datacenter-Core-1709-with-Containers-smalldisk"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-wsworker-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-wsw-${count.index}"
    admin_username = "${var.os_admin_user}"
    admin_password = "${var.os_adm_passwd}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = false
  }

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

# ********************************************************************************************************************************************************************
# ********************************************************************************************************************************************************************

 data "template_file" "workers_ansible" {
     template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
     count = "${var.count}"
     vars {
         name  = "${var.cluster_name}-worker-${count.index}"
         ip = "${element(azurerm_public_ip.worker.*.id, count.index)}"
     }
 }
