# Get initial variables
source ~/Anthos_sthlm/env

# RUN ./importvm.sh gke-admin-ws-200814-093901 (Use name of current admin WS)

export TF_VAR_aws_public_keys=""
export TF_VAR_aws_user_data=""
terraform import vsphere_virtual_machine.aws_vm /Stockholm/vm/$1

echo "VM imported, remember to source env for correct variables!!!"

# Copy ssh key to .ssh/
mkdir $PWD/.ssh/
sudo rm .ssh/gke-admin-workstation
scp -r delta@192.168.86.20:/home/delta/.ssh/gke-admin-workstation .ssh
sudo chmod 400 $PWD/.ssh/gke-admin-workstation