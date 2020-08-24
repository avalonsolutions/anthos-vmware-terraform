output "ivm_ip" {
  description = "IP to InstallVM"
  value       = "${vsphere_virtual_machine.ivm_vm.guest_ip_addresses[0]}"
}

output "nws_ip" {
  description = "IP to NetworkServices VM"
  value       = "${vsphere_virtual_machine.nws_vm.guest_ip_addresses[0]}"
}

output "linux_user" {
  value = var.linux_user
}
output "script_path" {
  value     = var.script_path
  sensitive = true
}

output "sa_path" {
  value     = var.sa_path
  sensitive = true
}

output "datastore2" {
  value = data.vsphere_datastore.datastore2.id
}

output "vsphere_resource_pool" {
  value = data.vsphere_resource_pool.pool.id
}

output "vm_network" {
  value = data.vsphere_network.vm_network.id
}

output "esxi_host" {
  value     = data.vsphere_host.esxi_host.id
  sensitive = true
}

output "google_project" {
  value = var.google_project
}
