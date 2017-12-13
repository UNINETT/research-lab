module "global" {
   source = "../../global-vars"

   cluster_name = "${var.cluster_name}"
   cluster_dns_domain = "${var.cluster_dns_domain}"
   allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
   allow_lb_from_v4 = "${var.allow_lb_from_v4}"
   allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
   ssh_public_key = "${var.ssh_public_key}"
   master_count = "${var.master_count}"
   worker_count = "${var.worker_count}"
   ingress_use_proxy_protocol = "${var.ingress_use_proxy_protocol}"
}

module "cluster" {
    source = "../../providers/azure/cluster"

    region = "${var.region}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
    subscription_id = "${var.subscription_id}"
    tenant_id = "${var.tenant_id}"

    os_admin_user = "${var.os_admin_user}"
    os_adm_passwd = "${var.os_adm_passwd}"

    tag_environment = "${var.tag_environment}"
    tag_activity = "${var.tag_activity}"

    cluster_name = "${module.global.cluster_name}"
    cluster_dns_domain = "${var.cluster_dns_domain}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
    coreos_image = "${var.coreos_image}"
    master_instance_type = "${var.master_instance_type}"
    master_count = "${module.global.master_count}"
    worker_instance_type = "${var.worker_instance_type}"
    worker_count = "${module.global.worker_count}"
    windowsserver_worker_count = "${var.windowsserver_worker_count}"
    ssh_public_key_file = "${module.global.ssh_public_key}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
}

data "template_file" "inventory_tail" {
   template = "$${section_vars}"
   vars = {
       section_vars = "[all:children]\n${module.global.cluster_name}\n[masters:children]\n${module.global.cluster_name}-masters\n[workers:children]\n${module.global.cluster_name}-workers\n[servers:vars]\nansible_ssh_user=core\nansible_python_interpreter=/home/core/bin/python\n[servers:children]\nmasters\nworkers\n"
   }
}

data "template_file" "inventory" {
   template = "$${cluster_inventory}\n$${inventory_tail}"
   vars {
       cluster_inventory = "${module.cluster.inventory}"
       inventory_tail = "${data.template_file.inventory_tail.rendered}"
   }
}

output "inventory" {
   value = "${data.template_file.inventory.rendered}"
}

# output "rg_name" {
#     value = "${module.cluster.rg_name}"
# }
