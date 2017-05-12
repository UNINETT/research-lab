provider "openstack" {
    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
}

# SSH Key
resource "openstack_compute_keypair_v2" "keypair" {
    name = "${var.cluster_name}"
    region = "${var.region}"
    public_key = "${file(var.ssh_public_key)}"
}

# Master nodes
resource "openstack_compute_instance_v2" "master" {
    count = "${var.master_count}"
    name = "${var.cluster_name}-master-${count.index}"
    region = "${var.region}"
    availability_zone = "${var.availability_zone}"
    image_id = "${var.coreos_image}"
    flavor_name = "${var.node_flavor}"
    key_pair = "${openstack_compute_keypair_v2.keypair.name}"
    security_groups = [
        "default",
        "${openstack_networking_secgroup_v2.ssh_access.id}",
        "${openstack_networking_secgroup_v2.kube_master.id}",
    ]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-master-${count.index}\n"

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.coreos_image}"
    }

}


# Worker nodes
resource "openstack_compute_instance_v2" "worker" {
    count = "${var.worker_count}"
    name = "${var.cluster_name}-worker-${count.index}"
    region = "${var.region}"
    availability_zone = "${var.availability_zone}"
    image_id = "${var.coreos_image}"
    flavor_name = "${var.worker_node_flavor}"
    key_pair = "${openstack_compute_keypair_v2.keypair.name}"
    security_groups = [
        "default",
        "${openstack_networking_secgroup_v2.ssh_access.id}",
        "${openstack_networking_secgroup_v2.kube_lb.id}",
    ]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.coreos_image}"
    }
}


data "template_file" "masters_ansible" {
    depends_on = ["openstack_compute_instance_v2.master"]
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.master_count}"
    vars {
        name  = "${element(openstack_compute_instance_v2.master.*.name, count.index)}"
        ip = "${element(openstack_compute_instance_v2.master.*.access_ip_v4, count.index)}"
        # ip = "${element(openstack_compute_instance_v2.etcd.*.network.0.fixed_ip_v4, count.index)}"
    }
}

data "template_file" "workers_ansible" {
    depends_on = ["openstack_compute_instance_v2.worker"]
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.worker_count}"
    vars {
        name  = "${element(openstack_compute_instance_v2.worker.*.name, count.index)}"
        ip = "${element(openstack_compute_instance_v2.worker.*.access_ip_v4, count.index)}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}

data "template_file" "inventory_tail" {
    template = "$${section_children}\n$${section_vars}"
    vars = {
        section_children = "[servers:children]\nmasters\nworkers"
        section_vars = "[servers:vars]\nansible_ssh_user=core\nansible_python_interpreter=/home/core/bin/python\n[all]\ncluster\n[all:children]\nservers\n[all:vars]\ncluster_name=${var.cluster_name}\ncluster_dns_domain=${var.cluster_dns_domain}\n"
    }
}

data "template_file" "inventory" {
    template = "\n[masters]\n$${master_hosts}\n[workers]\n$${worker_hosts}\n$${inventory_tail}"
    vars {
        master_hosts = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
        worker_hosts = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
        inventory_tail = "${data.template_file.inventory_tail.rendered}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}
