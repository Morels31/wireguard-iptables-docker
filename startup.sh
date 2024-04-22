#!/bin/bash

#Specify log folder location
logFolder="/logs/"



logg(){
	toLog="$(printf "%s - %s\n" "$(date +'%d/%m/%Y %T')" "$1")"
	echo "$toLog" | tee -a "$logFolder"startup-log
}

errorr(){
	err="$(printf "ERROR: %s. Exiting..." "$1")"
	logg "$err"
	exit 1
}



mkdir -p "$logFolder"
logg "Startup script started"



#Check needed files existence
test -f /etc/iptables/rules.v4 || errorr "/etc/iptables/rules.v4 file not found"

if [ ! -f /etc/iptables/rules.v6 ]; then
	logg "/etc/iptables/rules.v6 file not found, using default (DROP every ipv6 packet)"
	printf "*filter\n:INPUT DROP [0:0]\n:FORWARD DROP [0:0]\n:OUTPUT DROP [0:0]\nCOMMIT\n" > /etc/iptables/rules.v6
fi

test -f /etc/wireguard/wg0.conf || errorr "/etc/wireguard/wg0.conf file not found"



#Setup iptables
iptables-restore -n /etc/iptables/rules.v4 || errorr "Failed restoring ipv4 iptables"
ip6tables-restore -n /etc/iptables/rules.v6 || errorr "Failed restoring ipv6 iptables"

#Setup wireguard
wg-quick up wg0 || errorr "Failed starting wireguard client"



logg "Startup script completed successfully"
touch /started
while true; do sleep 3600; done
