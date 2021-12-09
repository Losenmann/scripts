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
