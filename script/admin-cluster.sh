#! /bin/bash
echo "Creating Admin-Cluster..."

# Switch folder
cd /home/ubuntu/

# Create and modify required files for admin-cluster

echo "hostconfig:
  dns: 192.168.86.1
  tod: 0.se.pool.ntp.org
  otherdns:
  - 8.8.8.8
  - 8.8.4.4
  othertod:
  - ntp.ubuntu.com
blocks:
  - netmask: 255.255.255.0
    gateway: 172.16.116.1
    ips:
    - ip: 172.16.116.10
      hostname: admin-host1
    - ip: 172.16.116.11
      hostname: admin-host2
    - ip: 172.16.116.12
      hostname: admin-host3
    - ip: 172.16.116.13
      hostname: admin-host4
    - ip: 172.16.116.14
      hostname: admin-host5
" > admin-hostconfig.yaml

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
    gateway: "172.16.116.1"
    ips:
    - ip: "172.16.116.18"
      hostname: "seesaw-vm"
" > admin-seesaw-hostconfig.yaml

sed -i "s~  dataDisk: \"\"~  dataDisk: \"admin-disk2.vmdk\"~" admin-cluster.yaml
sed -i "s~    type: dhcp~    type: static~" admin-cluster.yaml
sed -i "s~    # ipBlockFilePath: \"\"~    ipBlockFilePath: \"/home/ubuntu/admin-hostconfig.yaml\"~" admin-cluster.yaml
sed -i "s~  serviceCIDR: 10.96.232.0/24~  serviceCIDR: 10.196.116.0/24~" admin-cluster.yaml
sed -i "s~  podCIDR: 192.168.0.0/16~  podCIDR: 10.116.0.0/16~" admin-cluster.yaml
sed -i "s~    networkName: VM Network~    networkName: \"Admin Network\"~" admin-cluster.yaml
sed -i "s~    controlPlaneVIP: \"\"~    controlPlaneVIP: \"172.16.116.4\"~" admin-cluster.yaml
sed -i "s~    ipBlockFilePath: \"\"~    ipBlockFilePath: \"admin-seesaw-hostconfig.yaml\"~" admin-cluster.yaml
sed -i "s~    vrid: 0~    vrid: 172~" admin-cluster.yaml
sed -i "s~    masterIP: \"\"~    masterIP: \"172.16.116.7\"~" admin-cluster.yaml
sed -i "s~  projectID: \"\"~  projectID: \"anthos-sandbox-256114\"~" admin-cluster.yaml
sed -i "s~  clusterLocation: \"\"~  clusterLocation: \"europe-north1\"~" admin-cluster.yaml
sed -i "s~  serviceAccountKeyPath: \"\"~  serviceAccountKeyPath: \"/home/ubuntu/stackdriver-key.json\"~" admin-cluster.yaml

# Run gkectl prepare to initialize your vSphere environment
echo "Preparing vSphere environment"
## gkectl prepare --config admin-cluster.yaml --skip-validation-all

# Create and configure the VM for your Seesaw load balancer
echo "Creating load balancer"
##gkectl create loadbalancer --config admin-cluster.yaml

# Create admin-cluster
echo "Creating admin-cluster"
##gkectl create admin --config admin-cluster.yaml -v5 --skip-validation-all

echo "Admin-cluster deployed."
echo "Configuration complete."
# Logout
exit

# End of script