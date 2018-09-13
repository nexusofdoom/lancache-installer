#!/bin/bash
# Following Checks if you run as ROOT or not
if [[ "$EUID" -ne 0 ]]; then 
	echo "Please run as sudo"
	exit 1
fi

# Changeable variables
# Leaving defaults is fine
lc_srv_loc="/srv/lancache"
lc_dns1="8.8.8.8"
lc_dns2="4.2.2.2"

# Variables you should most likely not touch
# Unless you know what you are doing
lc_dl_dir="/usr/local/lancache"
lc_base_folder="$lc_dl_dir/lancache-installer"
lc_tmp_ip="/tmp/services_ips.txt"
lc_tmp_unbound="$lc_base_folder/etc/unbound/unbound.conf"
lc_tmp_hosts="$lc_base_folder/etc/hosts"
lc_tmp_yaml="$lc_base_folder/etc/netplan/01-netcfg.yaml"
lc_nginx_loc="/etc/nginx"
lc_unbound_loc="/etc/unbound"
lc_netdata="/etc/netdata/netdata.conf"
lc_network=$(hostname -I | awk '{ print $1 }')
lc_gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
if_name=$(ifconfig | grep flags | awk -F: '{print $1;}' | grep -Fvx -e lo)
lc_hostname=$(hostname)
TIMESTAMP=$(date +%s)

#Update packages
echo "Installing package updates..."
apt -y update
apt -y upgrade

#Install required packages
echo "Installing required updates..."
apt -y install nginx sniproxy unbound netdata

# Arrays used
# Services used and set ip for and created the lancache folders for
declare -a lc_services=(arena apple blizzard hirez gog glyph microsoft origin riot steam sony enmasse wargaming uplay zenimax digitalextremes pearlabyss)
# Installer Folders
declare -a lc_folders=(config data logs temp)
# Log Folders
declare -a lc_logfolders=(access error keys)

declare -a ip_eth=$(ip link show | grep ens | tr ":" " " | awk '{ print $2 }')
for int in ${ip_eth[@]}; do
	inet_eth=$(ip route get $lc_dns1 | tr " " " " | awk '{ print $5 }' )
	if [[ "$inet_eth" == "$int" ]]; then
		lc_ip_eth=$int
	fi
done

lc_ip=$(/bin/ip -4 addr show $lc_ip_eth | grep -oP "(?<=inet ).*(?=br)")
#1st octet
lc_ip_p1=$(echo ${lc_ip} | tr "." " " | awk '{ print $1 }')
#2nd octet
lc_ip_p2=$(echo ${lc_ip} | tr "." " " | awk '{ print $2 }')
#3rd octet
lc_ip_p3=$(echo ${lc_ip} | tr "." " " | awk '{ print $3 }')
#4th octet
lc_ip_p4=$(echo ${lc_ip} | tr "." " " | awk '{ print $4 }' | cut -f1 -d "/")
#Subnet
lc_ip_sn=$(echo ${lc_ip} | sed 's:.*/::' )

########### Update lancache config folder from github########################################
#Chcecking to see if directory exists before attempting to remove and add to prevent bash errors
if [[ -d $lc_base_folder ]]; then
	echo "Removing old lancache install directory..."
	rm -rfv $lc_base_folder
fi

if [[ ! -d $lc_base_folder ]]; then
	echo "Creating new lancache install directory..."
	mkdir -p $lc_base_folder
fi

cd $lc_dl_dir
git clone -b master http://github.com/nexusofdoom/lancache-installer
echo "Configuring IP Addressing..."
for service in ${lc_services[@]}; do
	# Check if the folder exists if not creates it
	if [[ ! -d "/tmp/data/$service" ]]; then
		mkdir -p /tmp/data/$service
	fi

	# Increases the IP with Every Run
	lc_ip_p4=$(expr $lc_ip_p4 + 1)
	# Writes the IP to A File to use it later on as Array
	# This for Netplan later on
	echo $lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4/$lc_ip_sn >> "$lc_tmp_ip"

	# This Changes the Unbound File with the correct IP Adresses
	sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'|g' $lc_tmp_unbound

	#This Corrects the Host File For The Gameservices
	sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'|g' $lc_tmp_hosts

	# This Corrects the Host File For The Netplan
	sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'/'$lc_ip_sn'|g' $lc_tmp_yaml
done

# This Changes the Unbound File with the correct IP Adresses for lc-host-ip
sed -i 's|lc-host-ip|'$lc_network'|g' $lc_tmp_unbound

# This Corrects the Host File For The Netplan with gateway
sed -i 's|lc-host-gateway|'$lc_gateway'|g' $lc_tmp_yaml

# This Corrects the Host File For The Netplan with primary network
sed -i 's|lc-host-network|'$lc_network'/'$lc_ip_sn'|g' $lc_tmp_yaml

# This Corrects the Host File For The Netplan with interface name
sed -i 's|lc-host-vint|'$if_name'|g' $lc_tmp_yaml

# This Corrects the loopback to bind to primary IP Address
sed -i 's|127.0.0.1|'$lc_network'|g' $lc_netdata

# This corrects the hostname pointing to the loopback
sed -i "s|lc-hostname|$lc_hostname|g" $lc_tmp_hosts

# This corrects lc-host-proxybind with the correct IP
sed -i "s|lc-host-proxybind|$lc_network|g" $lc_tmp_hosts

#for logfolder in ${lc_logfolders[@]}; do
	#Check if the folder exists if not creates it
	#if [[ ! -d "$lc_base_folder/$folder" ]]; then
		#mkdir -p $lc_base_folder/$logfolder
	#fi
#done

#Disable IPv6
echo "Disabling IPv6..."
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disable-ipv6.conf
sysctl -p /etc/sysctl.d/disable-ipv6.conf

### Change file limits
#need to get the limits into the /etc/security/limits.conf  * soft nofile  65536 * hard nofile  65536
echo "Setting security limits..."
mv /etc/security/limits.conf /etc/security/limits.conf.$TIMESTAMP.bak
echo '* soft nofile  65536' >> /etc/security/limits.conf
echo '* hard nofile  65536' >> /etc/security/limits.conf

# Change Ownership of folders
echo "Adding lancache directory structure and setting permissions..."
mkdir $lc_srv_loc
for i in ${lc_services[@]}
do
	mkdir -p ${lc_srv_loc}/data/${i}
done

for i in ${lc_logfolders[@]}
do
	mkdir -p ${lc_srv_loc}/logs/${i}
done
chown -R www-data:www-data $lc_srv_loc

# Setting specified DNS Servers
echo "Setting specified DNS Servers..."
sed -i "s|lc-dns1|$lc_dns1|g" $lc_base_folder/etc/nginx/nginx.conf
sed -i "s|lc-dns2|$lc_dns2|g" $lc_base_folder/etc/nginx/nginx.conf
sed -i "s|lc-dns1|$lc_dns1|g" $lc_base_folder/etc/nginx/lancache/resolver
sed -i "s|lc-dns2|$lc_dns2|g" $lc_base_folder/etc/nginx/lancache/resolver
sed -i "s|lc-dns1|$lc_dns1|g" $lc_tmp_yaml
sed -i "s|lc-dns2|$lc_dns2|g" $lc_tmp_yaml
sed -i "s|lc-dns1|$lc_dns1|g" $lc_tmp_unbound
sed -i "s|lc-dns2|$lc_dns2|g" $lc_tmp_unbound
sed -i "s|lc-dns1|$lc_dns1|g" $lc_base_folder/etc/sniproxy.conf

## Change the Proxy Bind in Lancache Configs
sed -i 's|lc-host-proxybind|'$lc_network'|g' $lc_base_folder/etc/nginx/sites-available/*.conf
## Doing the necessary changes for Lancache
mv $lc_nginx_loc/nginx.conf $lc_nginx_loc/nginx.conf.$TIMESTAMP.bak
cp $lc_base_folder/etc/nginx/nginx.conf $lc_nginx_loc/nginx.conf
#mkdir -p $lc_nginx_loc/conf/lancache
cp -rfv $lc_base_folder/etc/nginx/lancache $lc_nginx_loc
cp $lc_base_folder/etc/nginx/sites-available/*.conf $lc_nginx_loc/sites-available/

#Moving sniproxy configs
echo "Configuring sniproxy..."
mv /etc/default/sniproxy /etc/default/sniproxy.$TIMESTAMP.bak
cp $lc_base_folder/etc/default/sniproxy /etc/default/sniproxy
mv /etc/sniproxy.conf /etc/sniproxy.conf.$TIMESTAMP.bak
cp $lc_base_folder/etc/sniproxy.conf /etc/sniproxy.conf

# Moving unbound configs
echo "Configuring unbound..."
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.$TIMESTAMP.bak
cp $lc_base_folder/etc/unbound/unbound.conf /etc/unbound/unbound.conf

#Configuring startup services
echo "Configuring services to run on boot..."
systemctl enable nginx
systemctl enable sniproxy
systemctl enable unbound
systemctl enable netdata

# Move hosts and network interface values into place.
echo "Configuring network interfaces and hosts file..."
mv /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.$TIMESTAMP.bak
cp $lc_base_folder/etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
mv /etc/hosts /etc/hosts.$TIMESTAMP.bak
cp $lc_base_folder/etc/hosts /etc/hosts

echo "##############################################################################################"
echo "Current interface name: $if_name"
echo "##############################################################################################"
echo ""
#ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'
#if_name=$(ifconfig | grep flags | awk -F: '{print $1;}' | grep -Fvx -e lo)

### To Do Still
### Systemd Scripts for everything
### ... and stuff I forgot ...
### I have no problem with you redistributing this under your own name
### Just leave the following piece of line in there
### Base created by Geoffrey "bn_" @ https://github.com/bntjah
#echo $lc_base_folder
echo "##############################################################################################"
echo "DNS Server IP Address / Point Clients to Use this DNS Server: $lc_network"
echo "##############################################################################################"
echo ""
#echo $lc_base_folder
#echo $lc_ip_p4
#echo $lc_gateway
echo "##############################################################################################"
echo "Reboot System"
echo "##############################################################################################"
echo ""