#!/bin/bash
apt-get install libgeoip-dev -y
apt-get install locate -y
apt-get install net-tools -y
apt-get install screen -y
apt-get install git
apt-get install checkinstall docbook-xsl docbook-xsl-ns docbook-xsl-doc-html xsltproc -y
apt-get install nload iftop httpry iftop tcpdump tshark -y
apt-get install autotools-dev cdbs debhelper dh-autoreconf dpkg-dev gettext libev-dev libpcre3-dev pkg-config software-properties-common autotools-dev cdbs debhelper dh-autoreconf dpkg-dev gettext libev-dev libpcre3-dev libudns-dev pkg-config fakeroot devscripts -y 
apt-get install devscripts curl git unbound build-essential libpcre3 libpcre3-dev zlib1g-dev libreadline-dev libev4 libev-dev libncurses5-dev git libssl-dev -y
apt-get install curl git unbound build-essential libpcre3 zlib1g-dev libreadline-dev libncurses5-dev libssl-dev httpry libudns0 libudns-dev libev4 libev-dev devscripts automake libtool autoconf autotools-dev cdbs debhelper dh-autoreconf dpkg-dev gettext pkg-config fakeroot libpcre3-dev libgd2-xpm-dev libgeoip-dev -y
apt-get install uuid-dev -y
#get grub ready for old network settings
sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo IPv6 disabled
#Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disable-ipv6.conf
sysctl -p /etc/sysctl.d/disable-ipv6.conf

## Change Limits of the system for Lancache to work without issues
#need to get the limits into the /etc/security/limits.conf  * soft nofile  65536 * hard nofile  65536
echo '* soft nofile  65536' >> /etc/security/limits.conf
echo '* hard nofile  65536' >> /etc/security/limits.conf

echo "##############################################################################################"
echo Current interface name
#ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'
if_name="$ifconfig | grep flags | awk -F: '{print $1;}' | grep -Fvx -e lo"
echo "$if_name"
echo "##############################################################################################"
#need to edit /etc/network/interfaces for eth0 if not named that
echo "##############################################################################################"
echo Pleas edit /etc/network/interfaces to match your setup if not eth0 please change in that file
echo "##############################################################################################"
sleep 3
echo "#########################################################################################"
echo Please reboot your system after you edit interfaces file for the changes to take effect.
echo "#########################################################################################"
