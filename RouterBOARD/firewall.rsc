:global funcFire do={
# $ppps1 $ppps2 $ppps3 $ppps4
	/ip firewall filter{
		:if ($on_all = "true" || $on_scan = "true") do={add chain="input" protocol="tcp" psd=41,3s,3,1 action=add-src-to-address-list address-list="Blacklist" address-list-timeout=none-dynamic place-before="1" comment="TCP Port Scan Detect"
		:if ($on_all = "true" || $on_scan = "true") do={add chain="input" protocol="udp" psd=41,3s,3,1 action=add-src-to-address-list address-list="Blacklist" address-list-timeout=none-dynamic comment="UDP Port Scan Detect"
		:if ($on_all = "true" || $on_brut = "true") do={add chain="input" protocol="tcp" dst-port="22" connection-state="new" src-address-list="auth-st2" action="add-src-to-address-list" address-list="Blacklist" address-list-timeout="none-dynamic" comment="Brute-Force Detect #1"
		:if ($on_all = "true" || $on_brut = "true") do={add chain="input" protocol="tcp" dst-port="22" connection-state="new" src-address-list="auth-st1" action="add-src-to-address-list" address-list="auth-st2" address-list-timeout=5m comment="Brute-Force Detect #2"
		:if ($on_all = "true" || $on_brut = "true") do={add chain="input" protocol="tcp" dst-port="22" connection-state="new" action="add-src-to-address-list" address-list="auth-st1" address-list-timeout=5m comment="Brute-Force Detect #3"  
		:if ($on_all = "true" || $on_ping_pong = "true") do={add chain="input" protocol="icmp" packet-size=$ppps1 action="add-src-to-address-list" address-list="access-st1" address-list-timeout=10s comment="Ping Code #1"
		:if ($on_all = "true" || $on_ping_pong = "true") do={add chain="input" protocol="icmp" packet-size=$ppps2 src-address-list="access-st1" action="add-src-to-address-list" address-list="access-st2" address-list-timeout=10s comment="Ping Code #2"
		:if ($on_all = "true" || $on_ping_pong = "true") do={add chain="input" protocol="icmp" packet-size=$ppps3 src-address-list="access-st2" action="add-src-to-address-list" address-list="access-st3" address-list-timeout=10s comment="Ping Code #3"
		:if ($on_all = "true" || $on_ping_pong = "true") do={add chain="input" protocol="icmp" packet-size=$ppps4 src-address-list="access-st3" action="add-src-to-address-list" address-list="Whitelist" address-list-timeout=30m comment="Ping Code #4"
		:if ($on_all = "true" || $on_iptv = "true") do={add chain="input" protocol="igmp" in-interface=$varBridName action="accept" comment="IGMP Allow"};
		:if ($on_all = "true" || $on_ospf = "true") do={add chain="input" protocol="ospf" in-interface="all-ppp" action="accept" comment="OSPF Allow"};
		:if ($on_all = "true" || $on_snmp = "true") do={add chain="input" protocol="udp" dst-port="161" src-address-list="Whitelist" action="accept" comment="SNMP Allow"};
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=input connection-state=established,related,untracked action=accept comment="defconf: accept established,related,untracked"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=input connection-state=invalid action=drop comment="defconf: drop invalid"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=input protocol=icmp action=accept comment="defconf: accept ICMP"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=input dst-address=127.0.0.1 action=accept comment="defconf: accept to local loopback (for CAPsMAN)"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=input in-interface-list=!LAN src-address-list=!Whitelist action=drop comment="defconf: drop all not coming from LAN"
		:if ($on_all = "true" || $on_iptv = "true") do={add chain="forward" protocol="udp" dst-port="1234" action="accept" comment="Multicust Forward"};
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward ipsec-policy=in,ipsec action=accept comment="defconf: accept in ipsec policy"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward ipsec-policy=out,ipsec action=accept comment="defconf: accept out ipsec policy"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward connection-state=established,related action=fasttrack-connection comment="defconf: fasttrack"
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward action=accept comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward action=drop comment="defconf: drop invalid" connection-state=invalid
		:if ($on_all = "true" || $on_defconf = "true") do={add chain=forward action=drop comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
	}
	/ip firewall raw{
		add chain="prerouting" in-interface-list="WAN" src-address-list="Whitelist" action="accept" comment="Allow Whitelist";
		add chain="prerouting" in-interface-list="WAN" protocol=!icmp src-address-list="Blacklist" action="drop" comment="Drop Blacklist";
	}
/}
