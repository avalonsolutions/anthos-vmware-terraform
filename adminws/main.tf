terraform {
  backend "remote" {
    organization = "DevoteamCloudServices"

    workspaces {
      name = "anthos-vmware-terraform-adminws"
    }
  }
}

data "terraform_remote_state" "core" {
  backend = "remote"
  config = {
    organization = "DevoteamCloudServices"
    workspaces = {
      name = "anthos-vmware-terraform-core"
    }
  }
}
