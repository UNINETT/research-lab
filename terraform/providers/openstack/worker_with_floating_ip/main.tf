variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "floating_ip_pool" {}
variable "sec_groups" { type = "list" }

# Worker nodes
resource "openstack_compute_floatingip_v2" "worker" {
    count = "${var.count}"
    region = "${var.region}"
    pool = "${var.floating_ip_pool}"
}
resource "openstack_compute_instance_v2" "worker" {
    count = "${var.count}"
    name = "${var.cluster_name}-worker-${count.index}"
    region = "${var.region}"
    flavor_name = "${var.flavor}"
    key_pair = "${var.keypair}"

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    #   Connecting to the set network with the provided floating ip.
    network {
        uuid = "${var.network}"
    }

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "volume"
        uuid = "${var.image}"
        volume_size = 40
    }
}

resource "openstack_compute_floatingip_associate_v2" "worker" {
    region = "${var.region}"
    count = "${var.count}"
    floating_ip = "${openstack_compute_floatingip_v2.worker.*.address[count.index]}"
    instance_id = "${openstack_compute_instance_v2.worker.*.id[count.index]}"
}

data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.worker.*.name[count.index]}"
        ip = "${openstack_compute_floatingip_v2.worker.*.address[count.index]}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}
