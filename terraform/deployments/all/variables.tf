# Azure configuration
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_region" { default = "westeurope" }
variable "azure_master_instance_type" {}
variable "azure_worker_instance_type" {}
variable "azure_coreos_image" {}

# AWS configuration
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" { default = "eu-central-1" }
variable "aws_master_instance_type" {}
variable "aws_worker_instance_type" {}
variable "aws_coreos_image" {}

# UH-IAAS configuration
variable "uhiaas_auth_url" {}
variable "uhiaas_domain_name" {}
variable "uhiaas_tenant_name" {}
variable "uhiaas_user_name" {}
variable "uhiaas_password" {}
variable "uhiaas_region" {}
variable "uhiaas_worker_node_flavor" {}
variable "uhiaas_node_flavor" {}
variable "uhiaas_coreos_image" {}
variable "uhiaas_public_v4_network" {}
variable "uhiaas_availability_zone" {}

# Safespring configuration
variable "safespring_auth_url" {}
variable "safespring_domain_name" {}
variable "safespring_tenant_name" {}
variable "safespring_user_name" {}
variable "safespring_password" {}
variable "safespring_region" {}
variable "safespring_worker_node_flavor" {}
variable "safespring_node_flavor" {}
variable "safespring_coreos_image" {}
variable "safespring_public_v4_network" {}
variable "safespring_floating_ip_pool" {}


variable "csc_auth_url" {}
variable "csc_domain_name" {}
variable "csc_tenant_name" {}
variable "csc_user_name" {}
variable "csc_password" {}
variable "csc_region" {}
variable "csc_worker_node_flavor" {}
variable "csc_node_flavor" {}
variable "csc_coreos_image" {}
variable "csc_public_v4_network" {}
variable "csc_floating_ip_pool" {}

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
variable "ingress_use_proxy_protocol" {}
