# Raspbian-Router
This is a project to setup a router using a ethernet or a PPPoE connection and a WLAN card/adapter to share your internet. 

This simple tutorial is based on Raspbian Jessie Lite (2017-09-07).

## Installation 

### Prerequisites
* Connection over Ethernet
* A WLAN network card/adapter
* Raspbian Jessie (2017-09-07)

Required packages will be listed at the specific subsection.

### PPPoE
If you are already connected with a modem (or a standard router) you can skip this subsection and start with the router configuration. If you need a PPPoE connection just run the following commands
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
pppoe -I eth0 -A
```
and if this proceeds without any error add the [PPPoE-Service](pppoe-service.sh) script to your auto-start configuration. This is a tiny script to automatically connect with PPPPoE on boot. I added the script to `/etc/rc.local` but there are many more options. A Cronjob would be another good and easy solution.
If you reboot or run the script automatically the PPPoE connection will be established.

### Router configuration
First of all, I know there are multiple solutions to get this done but this was the first that worked for me and is quite fast with download rates up to 3.5 MB/s.

Firstly, we need the following two packages:
```bash
apt-get install hostapd udhcpd
```
After that we need to configure the following line of `/etc/udhcpd.conf`. 

Note: 
1. If you already have an IP-address with `192.168.0.x` over PPPoE or simple ethernet you need to set another IP-address. 
2. If your WLAN adapter is not named `wlan0` change it to the appropriate name. You will get the right id with `ifconfig`. The naming has changed in later linux versions.
```bash
start 192.168.0.20
end 192.168.0.50
interface wlan0
remaining yes
opt dns 8.8.8.8 8.8.4.4
opt subnet 255.255.255.0
opt lease 864000
```
After that comment out `DHCPD_ENABLED="no"` in `/etc/default/udhcpd`. After that we have to give the WLAN network adapter a static IP-Address as any router has.As for Raspbian Jessie this is no longe done by editing `/etc/network/interfaces`. We will edit `/etc/dhcpcd.conf` instead.
Therefore, uncomment and change the following lines to. Take into account that if your interface is not named `wlan0` change it to the one set above. Same goes for the IP-Address:
```bash
# Example static IP configuration
interface wlan0
static ip_address=192.168.0.1/24
static domain_name_servers=8.8.8.8 8.8.4.4
```
This sets the IP-address of the WLAN adapter to the static IP-address and tells it to use Googles DNS.

That was all the part for the DHCP server. We now need to establish a WLAN with the network adapter.
Therefore, edit `/etc/hostapd/hostapd.conf` to the following. You need to edit `YOUR_SSID` and `YOUR_PASSPHRASE`:
```bash
interface=wlan0
driver=nl80211
ssid=YOUR_SSID
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=YOUR_PASSPHRASE
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ieee80211n=1
``` 
If the signal is too bad try to change the channel. I believe to have luck with prime numbers so 7 might be a good choice. If you want your WLAN to be hidden write `ignore_broadcast_ssid=0` instead of the line above.

Now edit `/etc/default/hostapd` and uncomment and change `#DAEMON_CONF="" ` to ``. In addition, change uncomment `#net.ipv4.ip_forward=1` in `/etc/sysctl.conf` which actually enables the package forwarding. 

The rest of the settings including some firewall settings are done by the [wlan-service](wlan-service.sh) script. If you do not need a PPPoE connection but a simple ethernet connection than replace all `ppp0` with `eth0` (or the name of your ethernet adapter as mentioned above multiple times). The script needs to be executed after login. I used a cronjob for this task. Easily done with `crontab -e` and `@reboot /bin/sh /home/pi/wlan-service.sh`. After reboot (assuming you (auto-)login into user `pi`) the wlan should be established.


### Developer Notes

A fully automatic script to setup the router will follow at any time (depends on my workload).
