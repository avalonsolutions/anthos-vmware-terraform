terraform {
  backend "remote" {
    organization = "DevoteamCloudServices"

    workspaces {
      name = "anthos-vmware-terraform-core"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

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

