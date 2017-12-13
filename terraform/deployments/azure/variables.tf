# Access key & secret key for azure.
variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "region" { default = "westeurope" }

variable "os_admin_user" { default = "core" }
variable "os_adm_passwd" {}

variable "tag_environment" { default = "test" }
variable "tag_activity" { default = "uh-sky_researchlab" }

# References to machine types and coreos AMI image.
variable "master_instance_type" {}
variable "worker_instance_type" {}
variable "coreos_image" { default = "latest" }

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
variable "windowsserver_worker_count" { default = 0 }
variable "ingress_use_proxy_protocol" { default = "" }
