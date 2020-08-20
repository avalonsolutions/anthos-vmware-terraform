/*
module "user-cluster_vm" {
  source = "./modules/vsphere-virtual-machine"
  
  vsphere_template = data.vsphere_virtual_machine.template.id 
  host_name = "user_testvm"
  
  vsphere_resource_pool = data.vsphere_resource_pool.pool.id 
  vsphere_datastore = data.vsphere_datastore.datastore1.id 
  vsphere_host = data.vsphere_host.esxi_host.id
  vsphere_network = data.vsphere_network.vm_network.id
}
module "admin-cluster_vm" {
  source = "./modules/vsphere-virtual-machine"
  
  vsphere_template = data.vsphere_virtual_machine.template.id 
  host_name = "admin_testvm"
  
  vsphere_resource_pool = data.vsphere_resource_pool.pool.id 
  vsphere_datastore = data.vsphere_datastore.datastore1.id 
  vsphere_host = data.vsphere_host.esxi_host.id
  vsphere_network = data.vsphere_network.vm_network.id
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
