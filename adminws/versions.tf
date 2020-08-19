terraform {
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
