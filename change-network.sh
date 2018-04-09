#!/bin/bash
## DNS Related Settings
	lc_dns_ip=dnsip
	lc_dns_uname=username_to_connect_as
	lc_unbound_loc=/etc/unbound

## Other variables
	lc_base_folder=/usr/local/lancache
	lc_unbound_loc=/etc/unbound
	lc_ip_gw=$( /sbin/ip route | awk '/default/ { print $3 }' )
	lc_eth_int=$( cat $lc_base_folder/config/interface_used )

## Divide the ip in variables
	lc_eth_int=$( cat $lc_base_folder/config/interface_used )
	lc_ip=$(echo `sudo ifconfig $lc_eth_int 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'` )
	lc_eth_netmask=$( sudo ifconfig $lc_eth_int |sed -rn '2s/ .*:(.*)$/\1/p' )
	lc_ip_p1=$(echo ${lc_ip} | tr "." " " | awk '{ print $1 }')
	lc_ip_p2=$(echo ${lc_ip} | tr "." " " | awk '{ print $2 }')
	lc_ip_p3=$(echo ${lc_ip} | tr "." " " | awk '{ print $3 }')
	lc_ip_p4=$(echo ${lc_ip} | tr "." " " | awk '{ print $4 }')

## Increment the last IP digit for every Game
	lc_incr_arena=$((lc_ip_p4+1))
	lc_ip_arena=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_arena
	lc_incr_blizzard=$((lc_ip_p4+2))
	lc_ip_blizzard=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_blizzard
	lc_incr_gog=$((lc_ip_p4+3))
	lc_ip_gog=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_gog
	lc_incr_hirez=$((lc_ip_p4+4))
	lc_ip_hirez=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_hirez
	lc_incr_microsoft=$((lc_ip_p4+5))
	lc_ip_microsoft=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_microsoft
	lc_incr_origin=$((lc_ip_p4+6))
	lc_ip_origin=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_origin
	lc_incr_riot=$((lc_ip_p4+7))
	lc_ip_riot=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_riot
	lc_incr_steam=$((lc_ip_p4+8))
	lc_ip_steam=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_steam
	lc_incr_sony=$((lc_ip_p4+9))
	lc_ip_sony=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_sony
	lc_incr_tera=$((lc_ip_p4+10))
	lc_ip_tera=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_tera
	lc_incr_wargaming=$((lc_ip_p4+11))
	lc_ip_wargaming=$lc_ip_p1.$lc_ip_p2.$lc_ip_p3.$lc_incr_wargaming

## Create Tmp Folder
	if [ ! -d "$lc_base_folder/tmp_ssh" ]; then
		mkdir -p $lc_base_folder/tmp_ssh
	fi

## Preparing configuration for unbound
	sudo mkdir -p /$lc_base_folder/tmp_ssh/
	#cp $lc_dl_dir/lancache/unbound/unbound.conf $lc_base_folder/tmp_ssh/
	cp $lc_base_folder/unbound/unbound.conf $lc_base_folder/tmp_ssh/
	sed -i 's|lc-host-ip|'$lc_ip'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-proxybind|'$lc_ip'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-gw|'$lc_ip_gw'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-arena|'$lc_ip_arena'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-blizzard|'$lc_ip_blizzard'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-hirez|'$lc_ip_hirez'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-gog|'$lc_ip_gog'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-microsoft|'$lc_ip_microsoft'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-origin|'$lc_ip_origin'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-riot|'$lc_ip_riot'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-steam|'$lc_ip_steam'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-sony|'$lc_ip_sony'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-tera|'$lc_ip_tera'|g' $lc_base_folder/tmp_ssh/unbound.conf
	sed -i 's|lc-host-wargaming|'$lc_ip_wargaming'|g' $lc_base_folder/tmp_ssh/unbound.conf

## Make the Necessary Changes For The New Host File
	cp $lc_base_folder/hosts $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-hostname|'$lc_hn'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-proxybind|'$lc_ip'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-arena|'$lc_ip_arena'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-blizzard|'$lc_ip_blizzard'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-hirez|'$lc_ip_hirez'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-gog|'$lc_ip_gog'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-microsoft|'$lc_ip_microsoft'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-origin|'$lc_ip_origin'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-riot|'$lc_ip_riot'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-steam|'$lc_ip_steam'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-sony|'$lc_ip_sony'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-tera|'$lc_ip_tera'|g' $lc_base_folder/tmp_ssh/hosts
	sed -i 's|lc-host-wargaming|'$lc_ip_wargaming'|g' $lc_base_folder/tmp_ssh/hosts

## Copying everything to the right location
	sudo mv /etc/hosts /etc/hosts.bak
	sudo mv $lc_base_folder/tmp_ssh/hosts /etc/hosts

## Copy the unbound config over to Remote Unbound Server
	scp $lc_base_folder/tmp_ssh/unbound.conf $lc_dns_uname@$lc_dns_ip:$lc_unbound_loc/unbound.conf

## Removal of tmp files
	if [ -d "$lc_base_folder/tmp_ssh" ]; then
		rm -rf $lc_base_folder/tmp_ssh
	fi
	
## Restart DNS Service on the remote DNS
        ssh -t $lc_dns_uname@$lc_dns_ip "sudo service unbound restart"
