#============================================EXAMPLE============================================#
# $funcExpamle vExample="1244" "4321"                                                           #
#===========================================FUNCTIONS===========================================#
# $funcWifi vPsk="" vSsid2="" vSsid5=""                                                         #
# $funcIptv                                                                                     #
# $funcSnmp vCommunity="" vAddr="" vContact="" vLocat=""                                        #
#===========================================VARIABLES===========================================# 
# vCommunity - Community            | Default - "public"                                        #
# vAddr - Addresses                 | Default - 0.0.0.0/0                                       #
# vContact - ContactInfo            | Default - "expamle@local.com"                             #
# vLocat - location                 | Default - "Local"                                         #
# vPsk - Pre-Shared Key Wi-Fi       | Default - MAC address 1 interface(excluid ":")            #
# vSsid2 - SSID 2.4gHz              | Default - "MTAP-2.4"                                      #
# vSsid5 - SSID 5gHz                | Default - "MTAP-5"                                        #
#===========================================ERROR CODE==========================================#
# Err-02 - No bridges created, create at least 1 bridge                                         #
# Err-03 - No external connection, create at least 1 DHCP/PPPoE/L2TP connection                 #
# Err-04 - Operation mode not selected or incorrectly selected
#===============================================================================================#


:global funcWifi do={
:local vPsk; :local vSsid2; :local vSsid5;
	:if ([:len $vPsk] < 8) do={
		:for i from=0 to=([:len [/interface get number=0 mac-address]] - 1) do={
			:local char [:pick [/interface get number=0 mac-address] $i]; :if ($char = ":") do={
				:set $char ""}; :set $vPsk ($vPsk.$char)}};
	:if ([:len $vSsid2] = 0) do={:set vSsid2 value=MTAP-2.4};
	:if ([:len $vSsid5] = 0) do={:set vSsid2 value=MTAP-5};
	/interface{
		/wireless{
			security-profiles set numbers=0 mode=dynamic-keys authentication-types=wpa2-psk unicast-ciphers=aes-ccm group-ciphers=aes-ccm wpa2-pre-shared-key=$vPsk
			:foreach i in=[find (type="wlan")] do={reset-configuration numbers=$i};
			:foreach i in=[find (band~"5ghz")] do={set number=$i band=5ghz-onlyac channel-width=20/40/80mhz-XXXX ssid=$vSsid2};
			:foreach i in=[find (band~"2ghz")] do={set number=$i band=2ghz-b/g/n channel-width=20/40mhz-XX ssid=$vSsid5};
		}
			:foreach i in=[find (type="wlan")] do={set mode=ap-bridge wireless-protocol=802.11 security-profile=default \
			frequency-mode=manual-txpower country=no_country_set installation=indoor wmm-support=enabled bridge-mode=enabled \
			multicast-helper=full tx-power-mode=all-rates-fixed tx-power=17 disabled=no};
	}
/}

:global funcSnmp do={
:local vCommunity; :local vAddr; :local vContact; :local vLocat; :local vAuth; :local vEnc; :local vInterBr;
	:if ([:len $vCommunity] = 0) do={:set $vCommunity value="public"};
	:if ([:len $vAddr] = 0) do={:set $vAddr value=0.0.0.0/0};
	:if ([:len $vContact] = 0) do={:set $vContact value="expamle@local.com"};
	:if ([:len $vLocat] = 0) do={:set $vLocat value="Local"};
	{:local ibp1 value=0; :local ibp2 value=0;
		:foreach i in=[[/interface find type="bridge"] || [:error "Err-02: No bridges created"]] do={
			:set ibp1 value=[/interface bridge port print count-only where bridge=[/interface get $i value-name=name]];
			:if ($ibp1 > $ibp2) do={:set $ibp2 value=$ibp1; :set $vInterBr value=[/interface get $i value-name=name]}}};
	/certificate
	sign [add name=snmp-auth common-name=auth]; sign [add name=snmp-enc common-name=enc];
	:set $vAuth value=[get snmp-auth fingerprint]; :set $vEnc value=[get snmp-enc fingerprint];
	remove snmp-auth,snmp-enc;
	/snmp
	community set numbers=0 name=$vCommunity addresses=$vAddr security=private read-access=yes write-access=yes \
		authentication-protocol=SHA1 encryption-protocol=AES authentication-password=$vAuth encryption-password=$vEnc;
	set contact=$vContact location=$vLocat engine-id=[/system routerboard get serial-number] \
		trap-community=[/snmp community get 0 name] trap-version=3 enabled=yes;
	/ip firewall filter
	add chain=input comment="ADD_TEMP";
	print; :if ([find chain="input" protocol="udp" dst-port="161" in-interface=$vInterBr] = "") do={
		:if ([get number=0 action] = "passthrough") do={
			add chain="input" protocol="udp" dst-port="161" in-interface=$vInterBr action="accept" place-before=1 comment="SNMP Allow"} \
		else={add chain="input" protocol="udp" dst-port="161" in-interface=$vInterBr action="accept" place-before=0 comment="SNMP Allow"}};
	remove numbers=[find comment="ADD_TEMP"];
	:put "Protocol SNMP successfully configured";
/}

:global funcIptv do={
:local vInterWan; :local vInterBr;
	:if ([system package find name=multicast] = "") do={
		:local varVers value=[:pick [system resource get version] 0 ([:find [system resource get version] "("]-1)];
		:local varArch value=[system resource get architecture-name];
		:if ($varArch = "x86") do={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers.npk"} \
			else={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers-$varArch.npk"};
		system scheduler add name="Run IPTV Install" on-event="/import iptv.rsc; \$funcIptv" start-time="startup" interval=3s;
		:delay 3000ms;
		system reboot;
	} else={
		set $vInterWan value=[ip route get number=[[find dst-address=0.0.0.0/0] || [:error "Err-03: No WAN interfaces"]] vrf-interface];
		{:local ibp1 value=0; :local ibp2 value=0;
		:foreach i in=[[/interface find type="bridge"] || [:error "Err-02: No bridges created"]] do={
			:set ibp1 value=[/interface bridge port print count-only where bridge=[/interface get $i value-name=name]];
			:if ($ibp1 > $ibp2) do={:set $ibp2 value=$ibp1; :set $vInterBr value=[/interface get $i value-name=name]}}};
		/routing igmp-proxy
		interface add interface=$vInterWan alternative-subnets="0.0.0.0/0" upstream="yes";
		interface add interface=$vInterBr;
		/interface
		bridge set $vInterBr igmp-snooping="yes";
		:foreach i in=[find (type="wlan")] do={wireless set $i wmm-support="enabled" multicast-helper="full"};
		/ip firewall filter
		add chain=input comment="ADD_TEMP";
		print; :if ([find chain="input" protocol="igmp" in-interface=$vInterBr] = "") do={
			:if ([get number=0 action] = "passthrough") do={
				add chain="input" in-interface=$vInterBr protocol="igmp" action="accept" place-before=1 comment="IGMP Allow"} \
			else={add chain="input" in-interface=$vInterBr protocol="igmp" action="accept" place-before=0 comment="IGMP Allow"}};
		print; :if ([find chain="forward" protocol="udp" dst-port="1234"] = "") do={
			add chain="forward" protocol="udp" dst-port="1234" action="accept" place-before=1 comment="IPTV Forward"};
		remove numbers=[find comment="ADD_TEMP"];
		/system scheduler remove [find name="Run IPTV Install"];
		:put "Package IPTV successfully installed";
	}
/}
