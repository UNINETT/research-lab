# Security groups

variable "rg_name" {}
variable "region" {}
variable "cluster_name" {}

variable "tag_environment" {}
variable "tag_activity" {}

variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }

# Loadbalancer Public IP
#variable "api-lb_pip" {}
#variable "web-lb_pip" {}

variable "cidr" { default = "10.2.0.0/16" }

# Access rules
#Master nodes (port: 22,80,443,8443) -> allow_ssh_from_v4
#Worker nodes - xxx-worker-sg (port: 22,80,443) -> allow_ssh_from_v4
#API LB (masters) - allow_api_access_from_v4 (Port: 8443)
#Web LB (workers) - allow_lb_from_v4 (Port: 80 & 443) 

#######################################################################################################
# Master nodes

resource "azurerm_network_security_group" "master-sg" {
  name                = "${var.cluster_name}-master-sg"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_network_security_rule" "master-sg-sr-outbound" {
  name                        = "outbound-access-rule"
  priority                    = 150
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.cidr}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-master-sg"
  depends_on                  = ["azurerm_network_security_group.master-sg"]
}

# resource "azurerm_network_security_rule" "master-sg-sr-inbound" {
#   name                        = "inbound-access-rule"
#   priority                    = 150
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "${var.cidr}"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-master-sg"
#   depends_on                  = ["azurerm_network_security_group.master-sg"]
# }

resource "azurerm_network_security_rule" "master-sg-sr-ssh" {
  name                        = "ssh-access-rule${count.index}"
  priority                    = "20${count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix  = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-master-sg"
  depends_on                  = ["azurerm_network_security_group.master-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "master-sg-sr-http" {
  name                        = "http-access-rule${count.index}"
  priority                    = "25${count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix  = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-master-sg"
  depends_on                  = ["azurerm_network_security_group.master-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "master-sg-sr-https" {
  name                        = "https-access-rule${count.index}"
  priority                    = "30${count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix  = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-master-sg"
  depends_on                  = ["azurerm_network_security_group.master-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "master-sg-sr-kubectl" {
  name                        = "kubectl-access-rule${count.index}"
  priority                    = "35${count.index}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix  = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-master-sg"
  depends_on                  = ["azurerm_network_security_group.master-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

#######################################################################################################
# Worker nodes

resource "azurerm_network_security_group" "worker-sg" {
  name                = "${var.cluster_name}-worker-sg"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_network_security_rule" "worker-sg-sr-outbound" {
  name                       = "outbound-access-rule"
  priority                   = 150
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "${var.cidr}"
  destination_address_prefix = "*"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-worker-sg"
  depends_on                  = ["azurerm_network_security_group.worker-sg"]
}

# *******************************************************************************

resource "azurerm_network_security_rule" "worker-sg-sr-rdp" {
  name                       = "rdp-access-rule${count.index}"
  priority                   = "10${count.index}"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-worker-sg"
  depends_on                  = ["azurerm_network_security_group.worker-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "worker-sg-sr-ssh" {
  name                       = "ssh-access-rule${count.index}"
  priority                   = "20${count.index}"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-worker-sg"
  depends_on                  = ["azurerm_network_security_group.worker-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "worker-sg-sr-http" {
  name                       = "http-access-rule${count.index}"
  priority                   = "25${count.index}"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-worker-sg"
  depends_on                  = ["azurerm_network_security_group.worker-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

resource "azurerm_network_security_rule" "worker-sg-sr-https" {
  name                       = "https-access-rule${count.index}"
  priority                   = "30${count.index}"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "${element(var.allow_ssh_from_v4, count.index)}"
  #source_address_prefix       = "*"
  destination_address_prefix = "${var.cidr}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${var.cluster_name}-worker-sg"
  depends_on                  = ["azurerm_network_security_group.worker-sg"]
  count = "${length(var.allow_ssh_from_v4)}"
}

# *******************************************************************************


#######################################################################################################
#######################################################################################################
# API LB (masters) - allow_api_access_from_v4

# resource "azurerm_network_security_group" "api-sg" {
#   name                = "${var.cluster_name}-api-sg"
#   location            = "${var.region}"
#   resource_group_name = "${var.rg_name}"

#   tags {
#     environment = "${var.tag_environment}",
#     uninett_activity = "${var.tag_activity}"
#   }
# }

# resource "azurerm_network_security_rule" "api-sg-sr-outbound" {
#   name                        = "outbound-access-rule"
#   priority                    = 150
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "${var.cidr}"
#   destination_address_prefix  = "*"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-api-sg"
#   depends_on                  = ["azurerm_network_security_group.api-sg"]
# }

# resource "azurerm_network_security_rule" "api-sg-sr-inbound" {
#   name                        = "inbound-access-rule"
#   priority                    = 150
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "${var.cidr}"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-api-sg"
#   depends_on                  = ["azurerm_network_security_group.api-sg"]
# }

# resource "azurerm_network_security_rule" "api-sg-sr-kubectl" {
#   name                        = "kubectl-access-rule${count.index}"
#   #name                        = "kubectl-access-rule"
#   priority                    = "35${count.index}"
#   #priority                    = "350"
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "8443"
#   source_address_prefix       = "${element(var.allow_api_access_from_v4, count.index)}"
#   #source_address_prefix       = "*"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-api-sg"
#   depends_on                  = ["azurerm_network_security_group.api-sg"]
#   count = "${length(var.allow_api_access_from_v4)}"
# }

#######################################################################################################
# Web LB (workers) - allow_lb_from_v4

# resource "azurerm_network_security_group" "web-sg" {
#   name                = "${var.cluster_name}-web-sg"
#   location            = "${var.region}"
#   resource_group_name = "${var.rg_name}"

#   tags {
#     environment = "${var.tag_environment}",
#     uninett_activity = "${var.tag_activity}"
#   }
# }

# resource "azurerm_network_security_rule" "web-sg-sr-outbound" {
#   name                        = "outbound-access-rule"
#   priority                    = 150
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "${var.cidr}"
#   destination_address_prefix  = "*"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-web-sg"
#   depends_on                  = ["azurerm_network_security_group.web-sg"]
# }

# resource "azurerm_network_security_rule" "web-sg-sr-inbound" {
#   name                        = "inbound-access-rule"
#   priority                    = 150
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "${var.cidr}"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-web-sg"
#   depends_on                  = ["azurerm_network_security_group.web-sg"]
# }

# resource "azurerm_network_security_rule" "web-sg-sr-http" {
#   name                        = "http-access-rule${count.index}"
#   priority                    = "25${count.index}"
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "${element(var.allow_lb_from_v4, count.index)}"
#   #source_address_prefix       = "*"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-web-sg"
#   depends_on                  = ["azurerm_network_security_group.web-sg"]
#   count = "${length(var.allow_lb_from_v4)}"
# }

# resource "azurerm_network_security_rule" "web-sg-sr-https" {
#   name                        = "https-access-rule${count.index}"
#   priority                    = "30${count.index}"
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "443"
#   source_address_prefix       = "${element(var.allow_lb_from_v4, count.index)}"
#   #source_address_prefix       = "*"
#   destination_address_prefix  = "${var.cidr}"
#   resource_group_name         = "${var.rg_name}"
#   network_security_group_name = "${var.cluster_name}-web-sg"
#   depends_on                  = ["azurerm_network_security_group.web-sg"]
#   count = "${length(var.allow_lb_from_v4)}"
# }