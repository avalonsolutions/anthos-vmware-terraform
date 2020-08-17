output "ivm_ip" {
  description = "IP to InstallVM"
  value       = "${vsphere_virtual_machine.ivm_vm.guest_ip_addresses[0]}"
}

output "nws_ip" {
  description = "IP to NetworkServices VM"
  value       = "${vsphere_virtual_machine.nws_vm.guest_ip_addresses[0]}"
}

output "vsphere_user" {
  value = var.vsphere_user
}

output "linux_user" {
  value = var.linux_user
}

output "vsphere_server" {
  value = var.vsphere_server
}

output "script_path" {
  value = var.script_path
}

output "sa_path" {
  value = var.sa_path
}

// Uncomment and create this "dummy" resource when outputs are modified
/*
resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo \"Terraform outputs updated\""
  }
}
*/
