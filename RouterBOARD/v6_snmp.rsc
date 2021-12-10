# vCommunity - Community
# vAddr - Addresses
# vContact - ContactInfo
# vLocat - location
:global funcSnmp do={
:local vCommunity; :local vAddr; :local vContact; :local vLocat; :local vAuth; :local vEnc; :local vInterBr;
	:if ([:len $vCommunity] = 0) do={:set $vCommunity value="public"}; :if ([:len $vAddr] = 0) do={:set $vAddr value=0.0.0.0/0};
	:if ([:len $vContact] = 0) do={:set $vContact value="expamle@local.com"}; :if ([:len $vLocat] = 0) do={:set $vLocat value="Local"};
	{:local ibp1 value=0; :local ibp2 value=0;
		:foreach i in=[/interface find type="bridge"] do={
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
