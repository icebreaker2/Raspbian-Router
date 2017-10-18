#!/bin/sh

sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
sudo iptables -A FORWARD -i ppp0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o ppp0 -j ACCEPT
sudo service hostapd start
sudo service udhcpd start
