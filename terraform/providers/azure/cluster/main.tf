variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}

variable "os_admin_user" {}
variable "os_adm_passwd" {}

variable "tag_environment" {}
variable "tag_activity" {}

variable "region" {}
variable "cluster_name" {}
variable "cluster_dns_domain" {}
variable "ingress_use_proxy_protocol" {}
variable "coreos_image" {}
variable "master_instance_type" {}
variable "master_count" {}
variable "worker_instance_type" {}
variable "worker_count" {}
variable "windowsserver_worker_count" {}
variable "ssh_public_key_file" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

module "resourcegroup" {
   source = "../resourcegroup"

   tag_environment = "${var.tag_environment}"
   tag_activity = "${var.tag_activity}"

   cluster_name = "${var.cluster_name}"
   region = "${var.region}"
}

#module "loadbalancers" {
#   source = "../loadbalancer"
#   
#   region = "${var.region}"
#   rg_name = "${module.resourcegroup.rg_name}"
#   cluster_name = "${var.cluster_name}"
#}

module "securitygroups" {
   source = "../securitygroups"
   
   region = "${var.region}"
   rg_name = "${module.resourcegroup.rg_name}"
   cluster_name = "${var.cluster_name}"

   tag_environment = "${var.tag_environment}"
   tag_activity = "${var.tag_activity}"

   #api-lb_pip = "${module.loadbalancers.api-lb_pip}"
   #web-lb_pip = "${module.loadbalancers.web-lb_pip}"

   allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
   allow_lb_from_v4 = "${var.allow_lb_from_v4}"
   allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
}

module "networks" {
   source = "../networks"

   region = "${var.region}"
   rg_name = "${module.resourcegroup.rg_name}"
   cluster_name = "${var.cluster_name}"
}

 module "masters" {
   source = "../master"

   region = "${var.region}"
   rg_name = "${module.resourcegroup.rg_name}"
   cluster_name = "${var.cluster_name}"

   tag_environment = "${var.tag_environment}"
   tag_activity = "${var.tag_activity}"

   os_admin_user = "${var.os_admin_user}"
   os_adm_passwd = "${var.os_adm_passwd}"
   ssh_public_key_file = "${var.ssh_public_key_file}"

   subnet_id = "${module.networks.azure_subnet_id}"
   master_sg_id = "${module.securitygroups.master_sg_id}"

   #api-lb_bp-id = "${module.loadbalancers.api-lb_bp-id}"
   #api_sg_id = "${module.securitygroups.api_sg_id}"
   
   instance_type = "${var.master_instance_type}"
   image = "${var.coreos_image}"
   count = "${var.master_count}"
 }

  module "workers" {
   source = "../worker"

   region = "${var.region}"
   rg_name = "${module.resourcegroup.rg_name}"
   cluster_name = "${var.cluster_name}"

   tag_environment = "${var.tag_environment}"
   tag_activity = "${var.tag_activity}"

   os_admin_user = "${var.os_admin_user}"
   os_adm_passwd = "${var.os_adm_passwd}"
   ssh_public_key_file = "${var.ssh_public_key_file}"

   subnet_id = "${module.networks.azure_subnet_id}"
   worker_sg_id = "${module.securitygroups.worker_sg_id}"

   #web-lb_bp-id = "${module.loadbalancers.web-lb_bp-id}"
   #web_sg_id = "${module.securitygroups.web_sg_id}"
   
   instance_type = "${var.worker_instance_type}"
   image = "${var.coreos_image}"

   count = "${var.worker_count}"
   wscount = "${var.windowsserver_worker_count}"
 }