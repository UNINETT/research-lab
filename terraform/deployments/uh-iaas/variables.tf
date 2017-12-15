# Provider config
variable "auth_url" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}
variable "worker_node_flavor" {}
variable "node_flavor" {}
variable "coreos_image" {}
variable "network" {}
variable "availability_zone" {}

# Cluster data, needs to be set in local.tfvars
variable "cluster_name" {}
variable "cluster_dns_domain" {}

# Placeholder empty values of global vars to allow override from
# local.tfvars if wanted. The *actual* defaults are in global-vars.
variable "allow_ssh_from_v4" { type = "list", default = [] }
variable "allow_lb_from_v4" { type = "list", default = [] }
variable "allow_api_access_from_v4" { type = "list", default = [] }
variable "ssh_public_key" { default = "" }
variable "master_count" { default = 0 }
variable "worker_count" { default = 0 }
variable "ingress_use_proxy_protocol" { default = "" }
