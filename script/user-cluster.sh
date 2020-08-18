#! /bin/bash
echo "Creating User-Cluster..."

# Switch folder
cd /home/ubuntu/

# Create and modify required files for user-cluster

echo "hostconfig:
  dns: "192.168.86.1"
  tod: "0.se.pool.ntp.org"
  otherdns:
  - 8.8.8.8
  - 8.8.4.4
  othertod:
  - ntp.ubuntu.com
blocks:
  - netmask: 255.255.252.0
    gateway: 192.168.116.1
    ips:
    - ip: 192.168.116.15
      hostname: user-host1
    - ip: 192.168.116.16
      hostname: user-host2
    - ip: 192.168.116.17
      hostname: user-host3
" > user-hostconfig.yaml

echo "hostconfig:
  dns: "192.168.86.1"
  tod: "0.se.pool.ntp.org"
  otherdns:
  - "8.8.8.8"
  - "8.8.4.4"
  othertod:
  - "ntp.ubuntu.com"
blocks:
  - netmask: "255.255.255.0"
    gateway: "192.168.116.1"
    ips:
    - ip: "192.168.116.18"
      hostname: "seesaw-vm"
" > user-seesaw-hostconfig.yaml

sed -i "s~\<name: \"\"~name: \"boden-gke-cluster\"~" user-cluster.yaml
sed -i "s~    type: dhcp~    type: static~" user-cluster.yaml
sed -i "s~    # ipBlockFilePath: \"\"~    ipBlockFilePath: \"/home/ubuntu/user-hostconfig.yaml\"~" user-cluster.yaml
sed -i "s~  serviceCIDR:.*~  serviceCIDR: 10.196.216.0/24~" user-cluster.yaml
sed -i "s~  podCIDR:.*~  podCIDR: 10.216.0.0/16~" user-cluster.yaml
sed -i "s~    networkName: VM Network~    networkName: \"User Network\"~" user-cluster.yaml
sed -i "s~    controlPlaneVIP: \"\"~    controlPlaneVIP: \"172.16.116.112\"~" user-cluster.yaml
sed -i "s~    ingressVIP: \"\"~    ingressVIP: \"192.168.116.3\"~" user-cluster.yaml
sed -i "s~    ipBlockFilePath: \"\"~    ipBlockFilePath: \"user-seesaw-hostconfig.yaml\"~" user-cluster.yaml
sed -i "s~    vrid:.*~    vrid: 192~" user-cluster.yaml
sed -i "s~    masterIP: \"\"~    masterIP: \"192.168.116.7\"~" user-cluster.yaml
sed -i "s~- name:.*~- name: sthlm-pool-1~" user-cluster.yaml
# Set antiAffinityGroups to false to disable DRS rule creation if less than 3 vsphere hosts
sed -i "112s~  enabled: true~  enabled: false~" user-cluster.yaml
sed -i "s~  projectID: \"\"~  projectID: \"anthos-sandbox-256114\"~" user-cluster.yaml
sed -i "s~  clusterLocation: \"\"~  clusterLocation: \"europe-north1\"~" user-cluster.yaml
sed -i "s~  serviceAccountKeyPath: \"\"~  serviceAccountKeyPath: \"/home/ubuntu/stackdriver-key.json\"~" user-cluster.yaml
sed -i "s~  registerServiceAccountKeyPath: \"\"~  registerServiceAccountKeyPath: \"/home/ubuntu/register-key.json\"~" user-cluster.yaml
sed -i "s~  agentServiceAccountKeyPath: \"\"~  agentServiceAccountKeyPath: \"/home/ubuntu/connect-key.json\"~" user-cluster.yaml

# Create and configure the VM for your Seesaw load balancer
## gkectl create loadbalancer --kubeconfig kubeconfig --config user-cluster.yaml

# Create your user cluster
## gkectl create cluster --kubeconfig kubeconfig --config user-cluster.yaml

# echo "User-cluster deployed."
echo "Configuration complete."
# Logout
exit

# End of script