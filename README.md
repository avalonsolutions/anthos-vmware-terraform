# Install Anthos Admin & User Clusters (WIP)

## Prerequisites 

### Set Variables

To be able to complete this installation, the following variables needs to be set before Terraform can do its thing:
* vsphere_user
* vsphere_password
* vsphere_server
* linux_user
* user_password
* networkservices_host_name
* bastion_host_name
* admin_network_gw
* user_network_gw
* google_project
* sa_path
* script_path

These are best set as local environment variable to avoid that sensitive values are exposed <br/>
For example use export 'TF_VAR_vsphere_password=' as this will instruct Terraform to use this variable.
