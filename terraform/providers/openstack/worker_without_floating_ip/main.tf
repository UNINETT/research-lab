variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }
variable "availability_zone" {}

# Worker nodes
resource "openstack_compute_instance_v2" "worker" {
    count = "${var.count}"
    name = "${var.cluster_name}-worker-${count.index}"
    region = "${var.region}"
    flavor_name = "${var.flavor}"
    image_id = "${var.image}"
    key_pair = "${var.keypair}"
    availability_zone = "${var.availability_zone}"
    network = {
      name = "${var.network}"
    }

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.image}"
        #volume_size = 40
    }
}

data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.worker.*.name[count.index]}"
        ip = "${element(openstack_compute_instance_v2.worker.*.access_ip_v4, count.index)}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}
