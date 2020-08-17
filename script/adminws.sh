#! /bin/bash
echo "Configuring Admin-workstation..."

# Elevate to correct privileges
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Back to base path
cd ~

# Variables passed from terraform
NetworkServices=$1

# Add routes on Admin WS  to reach networks behind NetworkServicesVM
sudo ip route add 172.16.116.0/24 via $NetworkServices
sudo ip route add 192.168.116.0/24 via $NetworkServices

echo "Configuration complete."
# Logout
exit
# End of script