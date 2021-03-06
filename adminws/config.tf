provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

terraform {
  backend "remote" {
    organization = "DevoteamCloudServices"

    workspaces {
      name = "anthos-vmware-terraform-adminws"
    }
  }
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">= 0.13"
}
