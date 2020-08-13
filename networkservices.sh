#! /bin/bash

# Elevate to correct privileges
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
	echo "Password accepted, This will take a while..."
    exit $?
fi

# Change hostname
hostnamectl set-hostname 'NetworkServices'

# Check for and apply updates
apt update && apt upgrade -y

# Get interface names and ip to first interface
interface_array=()
for iface in $(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2}' | awk NF)
do
        interface_array+=("$iface")
done
export FIRST_INT=${interface_array[0]} SECOND_INT=${interface_array[1]} THIRD_INT=${interface_array[2]}
export IP=$(/sbin/ip -o -4 addr list $FIRST_INT | awk '{print $4}' | cut -d/ -f1)

# Change network interface addresses
tee -a /etc/network/interfaces << END

# Admin network interface
auto $SECOND_INT
iface $SECOND_INT inet static
    address 172.16.116.1/24

# User network interface
auto $THIRD_INT
iface $THIRD_INT inet static
    address 192.168.116.1/24
END

ifup $SECOND_INT $THIRD_INT

# Add routes to each network
ip route add 172.16.116.0/24 dev $SECOND_INT
ip route add 192.168.116.0/24 dev $THIRD_INT
ip route add 192.168.86.0/24 dev $FIRST_INT

# delete all existing rules.
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW ! -i $FIRST_INT -j ACCEPT
iptables -A FORWARD -i $FIRST_INT -o $SECOND_INT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $FIRST_INT -o $THIRD_INT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side.
iptables -A FORWARD -i $SECOND_INT -o $FIRST_INT -j ACCEPT
iptables -A FORWARD -i $THIRD_INT -o $FIRST_INT -j ACCEPT

# SNAT
iptables -t nat -A POSTROUTING ! -d 172.16.116.0/24 -o $FIRST_INT -j SNAT --to-source $IP
iptables -t nat -A POSTROUTING ! -d 192.168.116.0/24 -o $FIRST_INT -j SNAT --to-source $IP

# Don't forward from the outside to the inside.
iptables -A FORWARD -i $FIRST_INT -o $FIRST_INT -j REJECT

# Enable routing.
echo 1 > /proc/sys/net/ipv4/ip_forward

# Prepare for iptables-persistent install skipping manual inputs needed
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

apt-get -y install iptables-persistent

# Post-Install finished
echo "Post-Install successful, system rebooting"
echo "Once rebooted, connect via:"
echo $IP

# Restart VM
reboot 


# End of script