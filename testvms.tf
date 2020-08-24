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
module "migrate_vm" {
  source = "./modules/vsphere-virtual-machine"

  vsphere_template = data.vsphere_virtual_machine.template.id
  host_name        = "migrate-instance"

  vsphere_resource_pool = data.vsphere_resource_pool.pool.id
  vsphere_datastore     = data.vsphere_datastore.datastore1.id
  vsphere_host          = data.vsphere_host.esxi_host.id
  vsphere_network       = data.vsphere_network.vm_network.id
}
*/
