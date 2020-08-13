#! /bin/bash

# Elevate to correct privileges
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Back to base path
cd ~

# Variables passed from terraform
GOOGLE_PROJECT=$1
VSPHERE_USER=$2
VSPHERE_PASSWORD=$3
VSPHERE_SERVER=$4
LINUX_USER=$5

# Other variables
PWD=/home/$LINUX_USER
echo $PWD

# Check for and apply updates
apt update && apt upgrade -y

# Change hostname
hostnamectl set-hostname 'InstallVM'

### GCP setup

# Install Cloud SDK
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Make sure you have apt-transport-https installed and curl
sudo apt-get install apt-transport-https ca-certificates gnupg curl -y

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update and install the Cloud SDK and the the anthos-auth and kubectl components
sudo apt-get update && sudo apt-get install google-cloud-sdk -y && gcloud config set disable_usage_reporting false && sudo apt-get install kubectl google-cloud-sdk-anthos-auth -y

# Log in to Google Cloud using a service account and set default project
gcloud auth activate-service-account vmware-installer@anthos-sandbox-256114.iam.gserviceaccount.com --key-file=$PWD/gcp_account.json --project=$GOOGLE_PROJECT

# Enable the required APIs in your Google Cloud project
gcloud services enable \
    anthos.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com

# Download the gkeadm command-line tool, and make it executable
gsutil cp gs://gke-on-prem-release-public/gkeadm/1.4.1-gke.1/linux/gkeadm ./
chmod +x gkeadm

# Generating a template for the configuration file
./gkeadm create config

# Use sed to fill in the rest of the configuration file
export file="admin-ws-config.yaml" 

sed -i "s~  whitelistedServiceAccountKeyPath: \"\"~  whitelistedServiceAccountKeyPath: \"$PWD/whitelisted-key.json\"~" $file
sed -i "s~    address: \"\"~    address: \"$VSPHERE_SERVER\"~" $file
sed -i "s~    username: \"\"~    username: \"$VSPHERE_USER\"~" $file
sed -i "s~    password: \"\"~    password: \"$VSPHERE_PASSWORD\"~" $file
sed -i "s~  datacenter: \"\"~  datacenter: \"Stockholm\"~" $file
sed -i "s~  datastore: \"\"~  datastore: \"datastore2\"~" $file
sed -i "s~  cluster: \"\"~  cluster: \"Stockholm\"~" $file
sed -i "s~  network: \"\"~  network: \"VM Network\"~" $file
sed -i "s~  resourcePool: \"\"~  resourcePool: \"StockholmSmall/Resources\"~" $file
sed -i "s~  caCertPath: \"\"~  caCertPath: \"$PWD/vcenter-ca-cert.pem\"~" $file
sed -i "s~    ipAllocationMode: \"\"~    ipAllocationMode: \"dhcp\"~" $file

# If your vCenter server uses a certificate issued by the default VMware CA, download the certificate as follows
curl -k "https://photon-machine/certs/download.zip" > download.zip

# Install the unzip command, unzip the certificate file and copy to current folder
sudo apt-get install unzip
unzip download.zip
find certs/lin/ -name "*.0" -exec mv '{}' vcenter-ca-cert.pem \;

# Copy config files to $PWD
cp -r * $PWD/

# Create your admin workstation
./gkeadm create admin-workstation

# Post-Install finished
echo "Post-Install successful, system rebooting"
echo "Once rebooted, connect via:"

# Get interface names and ip to first interface
interface_array=()
for iface in $(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2}' | awk NF)
do
        interface_array+=("$iface")
done
export FIRST_INT=${interface_array[0]}
export IP=$(/sbin/ip -o -4 addr list $FIRST_INT | awk '{print $4}' | cut -d/ -f1)
echo $IP

# Restart VM
reboot 


# End of script