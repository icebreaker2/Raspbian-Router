# Raspbian-Router
This is a project to setup a router using a ethernet or a PPPoE connection and a WLAN network card/adapter to share your internet. 

This simple tutorial is based on Raspbian Jessie Lite (2017-09-07). There is a (experimental) script.

## Installation 

### Prerequisites
* Connection over Ethernet
* A WLAN network card/adapter

### PPPoE
Run the following commands
```bash
apt-get update
apt-get install ppp pppoe iproute2  
vim /etc/ppp/peers/aaisp
```
and add the following snippet to the file. `YOUR-USER-NAME` is to be replaced with the login id your ISP gave you. Note: If your ethernet connection is not `eth0` then also change line two. Typing ifconfig will get you the appropriate name of your ethernet connection.
```bash 
user YOUR-USER-NAME
plugin rp-pppoe.so eth0
noipdefault
defaultroute
hide-password
lcp-echo-interval 1
lcp-echo-failure 10
noauth
persist
maxfail 0
mtu 1492
noaccomp
default-asyncmap
+ipv6
ipv6cp-use-ipaddr
ifname pppoe-aaisp
```
Now setup the related password to the user login above.
```bash
vim /etc/ppp/chap-secrets
```
And then paste the following snippet in it. Do not forget to edit the `YOUR-USER-NAME` and `YOUR-USER-PASSWORD` where the last one was also given to you by your ISP.
```bash
# Secrets for authentication using CHAP
# client      server   secret                      IP addresses
YOUR-USER-NAME   *        YOUR-USER-PASSWORD
```
We will skip the part to handle ipv6 connections.
To test the connection run
```bash

```
and if this proceeds without any error add the [PPPoE-Service]() script to your auto-start configuration. This is a tiny script to automatically connect with PPPPoE on boot. I added the script to `/etc/rc.local` but there are many more options. A Cronjob would be another good and easy solution.
If you reboot or run the script automatically the PPPoE connection will be established.



### (Se)

A full automatic script to setup the router will follow at any time.
