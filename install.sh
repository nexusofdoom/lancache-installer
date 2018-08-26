#!/bin/bash
#Added universe repository
#apt-add-repository universe 
apt-get update -y
apt-get upgrade -y

#Install needed packacges.
apt-get install nginx unbound sniproxy screen -y
  
#Disable IP
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disable-ipv6.conf
sysctl -p /etc/sysctl.d/disable-ipv6.conf
echo IPv6 disabled

## Change Limits of the system for Lancache to work without issues
#need to get the limits into the /etc/security/limits.conf  * soft nofile  65536 * hard nofile  65536
echo '* soft nofile  65536' >> /etc/security/limits.conf
echo '* hard nofile  65536' >> /etc/security/limits.conf

echo "##############################################################################################"
echo Current interface name
#ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'
if_name=$(ifconfig | grep flags | awk -F: '{print $1;}' | grep -Fvx -e lo)
echo "$if_name"
#auto change interfacename to eth0
#sed -i -e 's/'$if_name'/eth0/g' /etc/network/interfaces
sleep 3
echo "#########################################################################################"
echo  Please run ./install-lancache.sh
echo "#########################################################################################"
