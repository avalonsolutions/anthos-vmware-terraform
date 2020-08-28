resource "vsphere_host_port_group" "pg_admin" {
  name                = "Admin Network"
  host_system_id      = data.vsphere_host.esxi_host.id
  virtual_switch_name = "vSwitch0"

  vlan_id = 1172

  allow_promiscuous = true
}

resource "vsphere_host_port_group" "pg_user" {
  name                = "User Network"
  host_system_id      = data.vsphere_host.esxi_host.id
  virtual_switch_name = "vSwitch0"

  vlan_id = 1192

  allow_promiscuous = true
}

resource "vsphere_virtual_machine" "ivm_vm" {
  name             = var.bastion_host_name
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

resource "vsphere_virtual_machine" "nws_vm" {
  name             = var.networkservices_host_name
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
    source      = "${var.script_path}/networkservices.sh"
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


data "vsphere_datastore" "datastore1" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_datastore" "datastore2" {
  name          = "datastore2"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "StockholmSmall/Resources"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "vm_network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "admin_network" {
  name          = vsphere_host_port_group.pg_admin.name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "user_network" {
  name          = vsphere_host_port_group.pg_user.name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "debian-10-template"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datacenter" "datacenter" {
  name = "Stockholm"
}

data "vsphere_host" "esxi_host" {
  name          = "192.168.86.150"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
