resource "vsphere_virtual_machine" "vm" {
  name             = var.host_name
  resource_pool_id = var.vsphere_resource_pool
  datastore_id     = var.vsphere_datastore
  host_system_id   = var.vsphere_host

  num_cpus = 1
  memory   = 2048
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = var.vsphere_network
  }

  disk {
    label = "disk0"
    size  = 16
  }

  clone {
    template_uuid = var.vsphere_template
  }
}
