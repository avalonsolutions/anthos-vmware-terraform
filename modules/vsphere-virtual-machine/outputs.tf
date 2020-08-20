output "vm_ip" {
  description = "IP to the VM"
  value       = "${vsphere_virtual_machine.vm.guest_ip_addresses[0]}"
}
