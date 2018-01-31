# Networks

variable "public_v4_network" {}
variable "cluster_name" {}
variable "cidr" { default = "10.2.0.0/24" }
variable "region" {}

resource "openstack_networking_network_v2" "network_1" {
  region = "${var.region}"
  name = "${var.cluster_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  region = "${var.region}"
  name = "${var.cluster_name}_subnet"
  network_id = "${openstack_networking_network_v2.network_1.id}"
  cidr = "${var.cidr}"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router_1" {
  region = "${var.region}"
  name = "${var.cluster_name}_router"
  external_gateway = "${var.public_v4_network}"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  region = "${var.region}"
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}
