#!/bin/sh

#Specify log folder location
logDir="/logs"

#Where the script expects needed files
configDir="/config"


logg(){
	toLog="$(printf "%s - %s\n" "$(date +'%d/%m/%Y %T')" "$1")"
	echo "$toLog" | tee -a $logDir/startup-log
}

errorr(){
	err="$(printf "ERROR: %s. Exiting..." "$1")"
	logg "$err"
	exit 1
}



mkdir -p $logDir
logg "Startup script started"



#Check needed files existence
test -r $configDir/rules.v4 || errorr "rules.v4 file not found"

if [ ! -r $configDir/rules.v6 ]; then
	logg "rules.v6 file not found, using default (DROP every ipv6 packet)"
	printf "*filter\n:INPUT DROP [0:0]\n:FORWARD DROP [0:0]\n:OUTPUT DROP [0:0]\nCOMMIT\n" > $configDir/rules.v6
fi

test -r $configDir/wg0.conf || errorr "wg0.conf file not found"
cp $configDir/wg0.conf /etc/wireguard/wg0.conf || errorr "Failed copying wg0.conf file"



#Setup iptables
iptables-restore -n $configDir/rules.v4 || errorr "Failed restoring ipv4 iptables"
ip6tables-restore -n $configDir/rules.v6 || errorr "Failed restoring ipv6 iptables"

#Setup wireguard
wg-quick up wg0 || errorr "Failed starting wireguard client"

if [ -x $configDir/custom-script.sh ]; then
	logg "Executing custom-script.sh"
	$configDir/custom-script.sh || errorr "custom-script.sh failed"
	logg "custom-script.sh completed successfully"
fi



logg "Startup script completed successfully"
touch /started
while true; do sleep 3600; done
