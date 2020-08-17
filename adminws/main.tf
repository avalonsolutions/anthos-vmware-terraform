provider "vsphere" {
  user           = data.terraform_remote_state.core.outputs.vsphere_user
  password       = var.vsphere_password
  vsphere_server = data.terraform_remote_state.core.outputs.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}


data "terraform_remote_state" "core" {
  backend = "local"

  config = {
    path = "/Users/engfors/github/devoteam/sthlm/anthos-vmware-terraform/terraform.tfstate"
  }
}

/*
# Terraform >= 0.12
resource "aws_instance" "foo" {
  # ...
  subnet_id = data.terraform_remote_state.core.outputs.subnet_id
}
*/
