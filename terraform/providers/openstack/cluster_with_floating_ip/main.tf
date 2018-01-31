variable "auth_url" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}
variable "worker_node_flavor" {}
variable "node_flavor" {}
variable "coreos_image" {}
variable "public_v4_network" {}
variable "cluster_name" {}
variable "cluster_dns_domain" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }
variable "ssh_public_key" { }
variable "master_count" { }
variable "worker_count" { }
variable "floating_ip_pool" { }
variable "ingress_use_proxy_protocol" {}

provider "openstack" {
    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
}

module "keypair" {
    source = "../keypair"

    name = "${var.cluster_name}"
    region = "${var.region}"
    pubkey_file = "${var.ssh_public_key}"
}

module "networks" {
    source = "../networks"
    region = "${var.region}"

    public_v4_network = "${var.public_v4_network}"
    cluster_name = "${var.cluster_name}"
}

module "securitygroups" {
    source = "../securitygroups"
    region = "${var.region}"

    cluster_name = "${var.cluster_name}"
    region = "${var.region}"
    allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${var.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
}

module "masters" {
    source = "../master_with_floating_ip"

    region = "${var.region}"
    floating_ip_pool = "${var.floating_ip_pool}"
    flavor = "${var.node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.master_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
}

module "workers" {
    source = "../worker_with_floating_ip"

    floating_ip_pool = "${var.floating_ip_pool}"
    region = "${var.region}"
    flavor = "${var.worker_node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.worker_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
}
