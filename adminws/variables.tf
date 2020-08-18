variable "vsphere_server" {
  default = "photon-machine.lan"
}

variable "vsphere_user" {
  default = "administrator@vsphere.local"
}
variable "vsphere_password" {
  description = "use environent variable for password (export TF_VAR_vpshere_password=)"
}

variable "user_password" {
  description = "use environent variable for password (export TF_VAR_user_password=)"
}

// Use source env to retrieve these
variable "aws_public_keys" {}
variable "aws_user_data" {}
variable "aws_host_name" {
  description = "Use 'source env' to retrieve these"
}

variable "private_key_path" {
  default = ".ssh/gke-admin-workstation"
}

