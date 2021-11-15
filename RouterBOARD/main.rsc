:local varWanEth value="ether1";
:local varBridName value="bridge";
:local varDhcpName value="dhcp-local";
:local varPoolName value="pool-local";
:local varMainNet value="192.168.88";
:local varLoopback value="192.168.98.1";
:local varWifiSsid value="SSID 2.4GHz"
:local varWifiSsid2 value="SSID 5GHz"
:local varWifiPass value="PASSWORD"


:local varL2tpName value="l2tp-out";
:local varL2tpServ value="10.0.0.1";
:local varL2tpUser value="L2TP_USER";
:local varL2tpPass value="L2TP_PASSWORD";
:local varL2tpEnc value="L2TP_IPSEC";

:local varSnmpName value="LOCAL";
:local varSnmpAddr value="10.0.0.1";
:local varSnmpAuth value="SNMP_AUTH";
:local varSnmpEnc value="SNMP_ENC";
:local varSnmpInfo value="EXAMPLE@LOCAL.COM";
:local varSnmpLoc value="SNMP_LOCALITY";
:local varSnmpEngineID value="SNMP_ENG";
:local varOspfAuth value="OSPF_AUTH";

:local varNetwork value="$varMainNet.0";
:local varAddress value="$varMainNet.1/24";
:local varDhcpAddr value="$varMainNet.0/24";
:local varDhcpGate value="$varMainNet.1";
:local varPoolDhcp value="$varMainNet.10-$varMainNet.254";



/interface
bridge add name=$varBridName igmp-snooping=yes
bridge add name="loopback"
list add name="WAN"; list add name="LAN"
list member add list=WAN interface=$varWanEth
list member add list=LAN interface=$varBridName
:foreach i in=[find (type="ether")&&(!(name="$varWanEth"))] do={bridge port add bridge=$varBridName interface=[/interface get $i name]}
:foreach i in=[find (type="ether")&&(!(name="$varWanEth"))] do={list member add list=LAN interface=[/interface get $i name]}
:foreach i in=[find (type="wlan")] do={bridge port add bridge=$varBridName interface=[/interface get $i name]}
:foreach i in=[find (type="wlan")] do={list member add list=LAN interface=[/interface get $i name]}
l2tp-client add name=$varL2tpName connect-to=$varL2tpServ user=$varL2tpUser password=$varL2tpPass ipsec-secret=$varL2tpEnc profile=default-encryption use-ipsec=yes allow-fast-path=yes allow=mschap2 disabled=no
# detect-internet set detect-interface-list=all; detect-internet set wan-interface-list=WAN



/routing
igmp-proxy interface add interface=$varWanEth alternative-subnets=0.0.0.0/0 upstream=yes
igmp-proxy interface add interface=$varBridName
ospf interface add interface=all authentication=md5 authentication-key=$varOspfAuth network-type=broadcast
ospf interface add interface=$varBridName network-type=broadcast passive=yes
ospf instance set numbers=0 router-id=$varLoopback



/ip
address add interface=$varBridName address=$varAddress network=$varNetwork
address add interface=loopback address="$varLoopback/32"
pool add name=$varPoolName ranges=$varPoolDhcp
dns set allow-remote-requests="yes"
dhcp-client add interface=$varWanEth disabled="no"
dhcp-server add name=$varDhcpName interface=$varBridName lease-time="04:00:00" address-pool=$varPoolName disabled="no"
dhcp-server network add address=$varDhcpAddr gateway=$varDhcpGate dns-server=$varDhcpGate ntp-server=$varDhcpGate
service disable api,api-ssl,ftp,telnet,www-ssl
upnp set enabled="yes"
upnp interfaces add interface=$varWanEth type="external"
upnp interfaces add interface=$varBridName type="internal"



/ip firewall nat
add chain="srcnat" out-interface-list="WAN" action="masquerade"
/ip firewall filter
add chain=input protocol=tcp psd=41,3s,3,1 action=add-src-to-address-list address-list="Blacklist" address-list-timeout=none-dynamic comment="TCP Port Scan Detect"
add chain=input protocol=udp psd=41,3s,3,1 action=add-src-to-address-list address-list="Blacklist" address-list-timeout=none-dynamic comment="UDP Port Scan Detect"
add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list="auth-st2" action=add-src-to-address-list address-list="Blacklist" address-list-timeout=none-dynamic comment="Brute-Force Detect #1"
add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list="auth-st1" action=add-src-to-address-list address-list="auth-st2" address-list-timeout=5m comment="Brute-Force Detect #2"
add chain=input protocol=tcp dst-port=22 connection-state=new action=add-src-to-address-list address-list="auth-st1" address-list-timeout=5m comment="Brute-Force Detect #3"  
add chain=input protocol=icmp packet-size=98 action=add-src-to-address-list address-list="access-st1" address-list-timeout=10s comment="Ping Code #1"
add chain=input protocol=icmp packet-size=98 action=add-src-to-address-list src-address-list="access-st1" address-list="access-st2" address-list-timeout=10s  comment="Ping Code #2"
add chain=input protocol=icmp packet-size=128 action=add-src-to-address-list src-address-list="access-st2" address-list="access-st3" address-list-timeout=10s  comment="Ping Code #3"
add chain=input protocol=icmp packet-size=128 action=add-src-to-address-list src-address-list="access-st3" address-list="Whitelist" address-list-timeout=30m  comment="Ping Code #4"
add chain=input protocol=igmp in-interface=$varBridName action=accept comment=IGMP
add chain=input protocol=ospf in-interface=all-ppp action=accept comment=OSPF
add chain=input protocol=udp dst-port=161 src-address-list="Whitelist" action=accept comment=SNMP
add chain=input connection-state=established,related,untracked action=accept comment="defconf: accept established,related,untracked"
add chain=input connection-state=invalid action=drop comment="defconf: drop invalid"
add chain=input protocol=icmp action=accept comment="defconf: accept ICMP"
add chain=input dst-address=127.0.0.1 action=accept comment="defconf: accept to local loopback (for CAPsMAN)"
add chain=input in-interface-list=!LAN src-address-list=!Whitelist action=drop comment="defconf: drop all not coming from LAN"
add chain=forward protocol=udp dst-port=1234 action=accept comment="Multicust"
add chain=forward ipsec-policy=in,ipsec action=accept comment="defconf: accept in ipsec policy"
add chain=forward ipsec-policy=out,ipsec action=accept comment="defconf: accept out ipsec policy"
add chain=forward connection-state=established,related action=fasttrack-connection comment="defconf: fasttrack"
add chain=forward action=accept comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add chain=forward action=drop comment="defconf: drop invalid" connection-state=invalid
add chain=forward action=drop comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall raw
add chain=prerouting in-interface-list=WAN src-address-list="Whitelist" action=accept
add chain=prerouting in-interface-list=WAN protocol=!icmp src-address-list="Blacklist" action=drop comment="Drop Blacklist"
/ip firewall address-list


/tool
bandwidth-server set enabled="no"

/snmp
community set numbers=0 name=$varSnmpName addresses=$varSnmpAddr security=private read-access=yes write-access=yes authentication-protocol=SHA1 encryption-protocol=AES authentication-password=$varSnmpAuth encryption-password=$varSnmpEnc
set contact=$varSnmpInfo location=$varSnmpLoc engine-id=$varSnmpEngineID trap-version=3 enabled=yes

/interface wireless
set numbers=0 mode=ap-bridge band=2ghz-b/g/n channel-width=20/40mhz-XX ssid=$varWifiSsid security-profile=default frequency=auto frequency-mode=manual-txpower country="united states" installation=indoor wmm-support=enabled bridge-mode=enabled tx-power-mode=all-rates-fixed tx-power=17 wireless-protocol=802.11 disabled=no
set numbers=1 mode=ap-bridge band=5ghz-onlyac channel-width=20/40/80mhz-XXXX ssid=$varWifiSsid2 security-profile=default frequency=auto frequency-mode=manual-txpower country="united states" installation=indoor wmm-support=enabled bridge-mode=enabled tx-power-mode=all-rates-fixed tx-power=17 wireless-protocol=802.11 disabled=no

/interface wireless security-profiles
set numbers=0 mode=dynamic-keys authentication-types=wpa2-psk unicast-ciphers=aes-ccm group-ciphers=aes-ccm wpa2-pre-shared-key=$varWifiPass
