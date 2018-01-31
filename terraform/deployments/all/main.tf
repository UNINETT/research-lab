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

module "azure_cluster" {
    source = "../../providers/azure/cluster"

    region = "${var.azure_region}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    subscription_id = "${var.azure_subscription_id}"
    tenant_id = "${var.azure_tenant_id}"

    cluster_name = "${module.global.cluster_name}-azure"
    cluster_dns_domain = "cluster-azure.${var.cluster_dns_domain}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
    coreos_image = "${var.azure_coreos_image}"
    master_instance_type = "${var.azure_master_instance_type}"
    master_count = "${module.global.master_count}"
    worker_instance_type = "${var.azure_worker_instance_type}"
    worker_count = "${module.global.worker_count}"
    ssh_public_key_file = "${module.global.ssh_public_key}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
}

module "aws_cluster" {
    source = "../../providers/aws/cluster"

    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    cluster_name = "${module.global.cluster_name}-aws"
    cluster_dns_domain = "cluster-aws.${var.cluster_dns_domain}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
    coreos_image = "${var.aws_coreos_image}"
    master_instance_type = "${var.aws_master_instance_type}"
    master_count = "${module.global.master_count}"
    worker_instance_type = "${var.aws_worker_instance_type}"
    worker_count = "${module.global.worker_count}"
    ssh_public_key_file = "${module.global.ssh_public_key}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
}

module "uhiaas_cluster" {
    source = "../../providers/openstack/cluster_without_floating_ip"

    auth_url = "${var.uhiaas_auth_url}"
    domain_name = "${var.uhiaas_domain_name}"
    tenant_name = "${var.uhiaas_tenant_name}"
    user_name = "${var.uhiaas_user_name}"
    password = "${var.uhiaas_password}"
    region = "${var.uhiaas_region}"
    worker_node_flavor = "${var.uhiaas_worker_node_flavor}"
    node_flavor = "${var.uhiaas_node_flavor}"
    coreos_image = "${var.uhiaas_coreos_image}"
    public_v4_network = "${var.uhiaas_public_v4_network}"
    availability_zone = "${var.uhiaas_availability_zone}"
    cluster_name = "${module.global.cluster_name}-uhiaas"
    cluster_dns_domain = "cluster-uhiaas.${var.cluster_dns_domain}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
    ssh_public_key = "${module.global.ssh_public_key}"
    master_count = "${module.global.master_count}"
    worker_count = "${module.global.worker_count}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
}

module "safespring_cluster" {
    source = "../../providers/openstack/cluster_with_floating_ip"

    auth_url = "${var.safespring_auth_url}"
    domain_name = "${var.safespring_domain_name}"
    tenant_name = "${var.safespring_tenant_name}"
    user_name = "${var.safespring_user_name}"
    password = "${var.safespring_password}"
    region = "${var.safespring_region}"
    worker_node_flavor = "${var.safespring_worker_node_flavor}"
    node_flavor = "${var.safespring_node_flavor}"
    coreos_image = "${var.safespring_coreos_image}"
    floating_ip_pool = "${var.safespring_floating_ip_pool}"
    public_v4_network = "${var.safespring_public_v4_network}"
    cluster_name = "${module.global.cluster_name}-safespring"
    cluster_dns_domain = "cluster-safespring.${var.cluster_dns_domain}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
    ssh_public_key = "${module.global.ssh_public_key}"
    master_count = "${module.global.master_count}"
    worker_count = "${module.global.worker_count}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
}

module "csc_cluster" {
    source = "../../providers/openstack/cluster_with_floating_ip"

    auth_url = "${var.csc_auth_url}"
    domain_name = "${var.csc_domain_name}"
    tenant_name = "${var.csc_tenant_name}"
    user_name = "${var.csc_user_name}"
    password = "${var.csc_password}"
    region = "${var.csc_region}"
    worker_node_flavor = "${var.csc_worker_node_flavor}"
    node_flavor = "${var.csc_node_flavor}"
    coreos_image = "${var.csc_coreos_image}"
    public_v4_network = "${var.csc_public_v4_network}"
    floating_ip_pool = "${var.csc_floating_ip_pool}"
    cluster_name = "${module.global.cluster_name}-csc"
    cluster_dns_domain = "cluster-csc.${var.cluster_dns_domain}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
    ssh_public_key = "${module.global.ssh_public_key}"
    master_count = "${module.global.master_count}"
    worker_count = "${module.global.worker_count}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
}

data "template_file" "inventory_tail" {
    template = "$${section_vars}"
    vars = {
        section_vars = "[all:children]\n${module.global.cluster_name}-aws\n${module.global.cluster_name}-safespring\n${module.global.cluster_name}-csc\n[masters:children]\n${module.global.cluster_name}-aws-masters\n${module.global.cluster_name}-safespring-masters\n${module.global.cluster_name}-csc-masters\n[workers:children]\n${module.global.cluster_name}-aws-workers\n${module.global.cluster_name}-safespring-workers\n${module.global.cluster_name}-csc-workers\n[servers:vars]\nansible_ssh_user=core\nansible_python_interpreter=/home/core/bin/python\n[servers:children]\nmasters\nworkers\n"
    }
}

data "template_file" "fed_inventory" {
    template = "$${federation_vars}"
    vars = {
        federation_vars = ""
    }
}

data "template_file" "inventory" {
    template = "$${aws_inventory}\n$${safespring_inventory}\n$${csc_inventory}\n$${fed_inventory}\n$${inventory_tail}"
    vars {
        aws_inventory = "${module.aws_cluster.inventory}"
        #uhiaas_inventory = "${module.uhiaas_cluster.inventory}"
        safespring_inventory = "${module.safespring_cluster.inventory}"
        csc_inventory = "${module.csc_cluster.inventory}"
        fed_inventory = "${data.template_file.fed_inventory.rendered}"
        inventory_tail = "${data.template_file.inventory_tail.rendered}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}
