#!/bin/bash
# Following Checks if you run as ROOT or not
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Variables you should most likely not touch
# Unless you know what you are doing
lc_base_folder=/usr/local/lancache
lc_tmp_ip=/tmp/services_ips.txt
lc_tmp_unbound=$lc_base_folder/temp/unbound.conf
lc_tmp_hosts=$lc_base_folder/temp/hosts
lc_nginx_loc=/etc/nginx
#lc_sniproxy_bin=/usr/local/sbin/sniproxy
lc_srv_loc=/srv/lancache
lc_unbound_loc=/etc/unbound
#lc_nginx_url=http://nginx.org/download/nginx-$lc_nginx_version.tar.gz
lc_tmp_yaml=$lc_base_folder/temp/01-lancache.yaml
lc_dl_dir=/tmp/lancache
## Divide the ip in variables
lc_ip_nginx=$( ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
TIMESTAMP=$(date +%s)


# Arrays used
# Services used and set ip for and created the lancache folders for
declare -a lc_services=(arena apple blizzard hirez gog glyph microsoft origin riot steam sony enmasse wargaming uplay zenimax digitalextremes pearlabyss)
# Installer Folders
declare -a lc_folders=(config data logs temp)
# Log Folders
declare -a lc_logfolders=(Access Error Keys)

declare -a ip_eth=$( ip link show | grep ens | tr ":" " " | awk '{ print $2 }' )
for int in ${ip_eth[@]}; do
        inet_eth=$( ip route get 8.8.8.8 | tr " " " " | awk '{ print $5 }'  )
        if [ "$inet_eth" == "$int" ]; then
                lc_ip_eth=$int
        fi
done

lc_ip=$( /bin/ip -4 addr show $lc_ip_eth | grep -oP "(?<=inet ).*(?=br)" )
#1st octet
lc_ip_p1=$(echo ${lc_ip} | tr "." " " | awk '{ print $1 }')
#2nd octet
lc_ip_p2=$(echo ${lc_ip} | tr "." " " | awk '{ print $2 }')
#3rd octet
lc_ip_p3=$(echo ${lc_ip} | tr "." " " | awk '{ print $3 }')
#4th octet
lc_ip_p4=$(echo ${lc_ip} | tr "." " " | awk '{ print $4 }' | cut -f1 -d "/" )
#Subnet
lc_ip_sn=$(echo ${lc_ip} | sed 's:.*/::' )


########### Update lancache config folder from github########################################
mkdir $lc_dl_dir
cd $lc_dl_dir
git clone -b master http://github.com/nexusofdoom/lancache-installer


#if [ ! -f "$lc_tmp_ip" ]; then
        for service in ${lc_services[@]}; do
                        # Check if the folder exists if not creates it
                        if [ ! -d "/tmp/data/$service" ]; then
                                mkdir -p /tmp/data/$service
                        fi

                        # Increases the IP with Every Run
                        lc_ip_p4=$(expr $lc_ip_p4 + 1)
                        # Writes the IP to A File to use it later on as Array
                        # This for Netplan later on
                        echo $lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4/$lc_ip_sn >> "$lc_tmp_ip"

                        # This Changes the Unbound File with the correct IP Adresses
                        sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'|g' $lc_tmp_unbound

                        # This Corrects the Host File For The Gameservices
                        sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'|g' $lc_tmp_hosts

                        # This Corrects the Host File For The Netplan
                        sed -i 's|lc-host-'$service'|'$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_ip_p4'|g' $lc_tmp_yaml

#                done
#        else
#                echo Sorry Something went wrong as the file $lc_tmp_ip already exists!
#fi

for logfolder in ${lc_logfolders[@]}; do
        # Check if the folder exists if not creates it
        if [ ! -d "$lc_base_folder/$folder" ]; then
                mkdir -p $lc_base_folder/$logfolder
        fi
done


#Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disable-ipv6.conf
sysctl -p /etc/sysctl.d/disable-ipv6.conf
echo IPv6 disabled


### Change file limits
        sudo mv /etc/security/limits.conf /etc/security/limits.conf.$TIMESTAMP.bak
        #need to get the limits into the /etc/security/limits.conf  * soft nofile  65536 * hard nofile  65536
        echo '* soft nofile  65536' >> /etc/security/limits.conf
        echo '* hard nofile  65536' >> /etc/security/limits.conf

# Change Ownership of folders
chown -R www-data:www-data /srv/lancache

#Install Nginx Server
apt install nginx -y

## Change the Proxy Bind in Lancache Configs
sed -i 's|lc-host-proxybind|'$lc_ip_nginx'|g' $lc_nginx_loc/etc/nginx/sites-available/*.conf
## Doing the necessary changes for Lancache
mv $lc_nginx_loc/nginx.conf $lc_nginx_loc/nginx.conf.$TIMESTAMP.bak
cp $lc_dl_dir/etc/nginx/nginx.conf $lc_nginx_loc/nginx.conf
mkdir -p $lc_nginx_loc/conf/lancache
cp $lc_dl_dir/etc/nginx/lancache/* $lc_nginx_loc/lancache
cp $lc_dl_dir/etc/nginx/sites-available/*.conf $lc_nginx_loc/sites-available/


# Check if a previous workdir contains sniproxy
# If not download it and compile it again
apt install sniproxy -y

##enable sniproxy and move configs
mv /etc/default/sniproxy /etc/default/sniproxy.$TIMESTAMP.bak
cp $lc_dl_dir/etc/default/sniproxy  /etc/default/sniproxy
mv /etc/default/sniproxy /etc/default/sniproxy.$TIMESTAMP.bak
cp $lc_dl_dir/etc/sniproxy.conf   /etc/sniproxy.conf


### To Do Still
### Change the proxy bind
### Systemd Scripts for everything
### ... and stuff I forgot ...
### I have no problem with you redistributing this under your own name
### Just leave the following piece of line in there
### Base created by Geoffrey "bn_" @ https://github.com/bntjah
