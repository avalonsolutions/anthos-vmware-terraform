resource "vsphere_virtual_machine" "aws_vm" {
  name             = var.aws_host_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore2.id
  host_system_id   = data.vsphere_host.esxi_host.id

  enable_disk_uuid = true
  enable_logging   = true
  num_cpus         = 4
  memory           = 8192

  # annotation = "Cluster Installed"

  network_interface {
    network_id = data.vsphere_network.vm_network.id
  }

  disk {
    size           = 50
    label          = "disk0"
    unit_number    = 0
    keep_on_remove = true
  }

  disk {
    size           = 1
    label          = "disk1"
    unit_number    = 1
    keep_on_remove = true
  }

  vapp {
    properties = {
      "hostname"    = var.aws_host_name
      "public-keys" = var.aws_public_keys
      "user-data"   = var.aws_user_data
    }

  }
}

resource "null_resource" "deploy_cluster" {

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = vsphere_virtual_machine.aws_vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.script_path}/adminws.sh"
    destination = "/tmp/adminws.sh"
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.script_path}/admin-cluster.sh"
    destination = "/tmp/admin-cluster.sh"
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.script_path}/user-cluster.sh"
    destination = "/tmp/user-cluster.sh"
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.sa_path}/stackdriver-key.json"
    destination = "/home/ubuntu/stackdriver-key.json"
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.sa_path}/register-key.json"
    destination = "/home/ubuntu/register-key.json"
  }

  provisioner "file" {
    source      = "${data.terraform_remote_state.core.outputs.sa_path}/connect-key.json"
    destination = "/home/ubuntu/connect-key.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/adminws.sh",
      "chmod +x /tmp/admin-cluster.sh",
      "chmod +x /tmp/user-cluster.sh",
      "cd /tmp && echo ${var.user_password} | sudo -S ./adminws.sh ${data.terraform_remote_state.core.outputs.nws_ip}",
      "cd /tmp && echo ${var.user_password} | sudo -S ./admin-cluster.sh ${var.user_password}",
      "cd /tmp && echo ${var.user_password} | sudo -S ./user-cluster.sh ${var.user_password}"
    ]
  }
}
