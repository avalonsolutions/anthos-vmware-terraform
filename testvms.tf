/*
resource "vsphere_virtual_machine" "user-cluster_vm" {
  name             = "testvm1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore1.id
  host_system_id   = data.vsphere_host.esxi_host.id

  num_cpus = 1
  memory   = 2048
  guest_id = "ubuntu64Guest"

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
}
resource "vsphere_virtual_machine" "admin-cluster_vm" {
  name             = "testvm2"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore1.id
  host_system_id   = data.vsphere_host.esxi_host.id

  num_cpus = 1
  memory   = 2048
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.admin_network.id
  }

  disk {
    label = "disk0"
    size  = 16
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}
*/
resource "vsphere_virtual_machine" "migrate_vm" {
  name             = "migrate-instance"
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
}
