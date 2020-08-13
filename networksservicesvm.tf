resource "vsphere_virtual_machine" "nws_vm" {
  name             = var.nws_host_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore1.id
  host_system_id   = data.vsphere_host.esxi_host.id

  num_cpus = 1
  memory   = 2048
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.vm_network.id
  }

  network_interface {
    network_id = data.vsphere_network.admin_network.id
  }

  network_interface {
    network_id = data.vsphere_network.user_network.id
  }

  disk {
    label = "disk0"
    size  = 16
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  provisioner "file" {
    source      = "/Users/engfors/github/devoteam/sthlm/networkservices.sh"
    destination = "/tmp/script.sh"
  }

  // Script will fail if there's not 3 interfaces on the VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "cd /tmp && echo ${var.user_password} | sudo -S ./script.sh",
    ]
  }

  connection {
    type     = "ssh"
    user     = var.linux_user
    password = var.user_password
    host     = self.guest_ip_addresses[0]
  }
}
