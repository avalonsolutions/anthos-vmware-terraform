resource "vsphere_virtual_machine" "ivm_vm" {
  name             = var.ivm_host_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore1.id
  host_system_id   = data.vsphere_host.esxi_host.id

  num_cpus = 1
  memory   = 2048
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.vm_network.id
  }

  disk {
    label = "disk0"
    size  = 16
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  provisioner "file" {
    source      = "${var.script_path}/installvm.sh"
    destination = "/tmp/installscript.sh"
  }

  provisioner "file" {
    source      = "${var.sa_path}/whitelisted-key.json"
    destination = "/home/${var.linux_user}/whitelisted-key.json"
  }

  provisioner "file" {
    source      = "${var.sa_path}/gcp_account.json"
    destination = "/home/${var.linux_user}/gcp_account.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installscript.sh",
      "cd /tmp && echo ${var.user_password} | sudo -S ./installscript.sh ${var.google_project} ${var.vsphere_user} ${var.vsphere_password} ${var.vsphere_server} ${var.linux_user}",
    ]
  }

  connection {
    type     = "ssh"
    user     = var.linux_user
    password = var.user_password
    host     = self.guest_ip_addresses[0]
  }
}

output "ivm_ip" {
  description = "IP to InstallVM"
  value       = "${vsphere_virtual_machine.ivm_vm.guest_ip_addresses[0]}"
}

resource "null_resource" "deploy_admin-cluster" {

  connection {
    type     = "ssh"
    user     = var.linux_user
    password = var.user_password
    host     = vsphere_virtual_machine.ivm_vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    source      = "${var.script_path}/adminws.sh"
    destination = "/tmp/adminws.sh"
  }

  provisioner "file" {
    source      = "${var.script_path}/admin-cluster.sh"
    destination = "/tmp/admin-cluster.sh"
  }

  provisioner "file" {
    source      = "${var.script_path}/user-cluster.sh"
    destination = "/tmp/user-cluster.sh"
  }

  provisioner "file" {
    source      = "${var.sa_path}/stackdriver-key.json"
    destination = "/home/${var.linux_user}/stackdriver-key.json"
  }

  provisioner "file" {
    source      = "${var.sa_path}/register-key.json"
    destination = "/home/${var.linux_user}/register-key.json"
  }

  provisioner "file" {
    source      = "${var.sa_path}/connect-key.json"
    destination = "/home/${var.linux_user}/connect-key.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/adminws.sh",
      "cd /tmp && echo ${var.user_password} | sudo -S ./adminws.sh ${var.user_password}"
    ]
  }
}
