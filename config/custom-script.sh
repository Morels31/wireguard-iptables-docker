#!/bin/sh


gateway="$(ip route list | grep default | grep -Po '\d+\.\d+\.\d+\.\d+')"

ip route add YOUR_LOCAL_SUBNET via $gateway dev eth0 || exit 1
