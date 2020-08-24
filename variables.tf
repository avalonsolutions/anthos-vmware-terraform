variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "linux_user" {
  description = "use environent variable for user (export TF_VAR_linux_user=)"
}

variable "vsphere_password" {
  description = "use environent variable for password (export TF_VAR_vpshere_password=)"
}

variable "vsphere_server" {
  description = "set to name or ip of the vpshere_server (export TF_VAR_vpshere_password=)"
}

variable "networkservices_host_name" {
  default = "NetworkServices"
}

variable "bastion_host_name" {
  default = "InstallVM"
}

variable "user_network_gw" {
  default = "192.168.116.1"
}

variable "admin_network_gw" {
  default = "172.16.116.1"
}

variable "user_password" {
  description = "use environent variable for password (export TF_VAR_user_password=)"
}

variable "google_project" {
  default = "anthos-sandbox-256114"
}

variable "sa_path" {
  description = "use environent variable for password (export TF_VAR_sa_path=)"
}

variable "script_path" {
  description = "use environent variable for password (export TF_VAR_script_path=)"
}
