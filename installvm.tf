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
    source      = "/Users/engfors/github/devoteam/sthlm/anthos-vmware-terraform/installvm.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "/Users/engfors/Anthos_sthlm/sa/whitelisted-key.json"
    destination = "/home/${var.linux_user}/whitelisted-key.json"
  }

  provisioner "file" {
    source      = "/Users/engfors/Anthos_sthlm/sa/gcp_account.json"
    destination = "/home/${var.linux_user}/gcp_account.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "cd /tmp && echo ${var.user_password} | sudo -S ./script.sh ${var.google_project} ${var.vsphere_user} ${var.vsphere_password} ${var.vsphere_server} ${var.linux_user}",
    ]
  }

  connection {
    type     = "ssh"
    user     = var.linux_user
    password = var.user_password
    host     = self.guest_ip_addresses[0]
  }
}
