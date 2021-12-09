# vCommunity - Community
# vAddr - Addresses
# vContact - ContactInfo
# vLocat - location
:global funcSnmp do={
:local vAuth; :local vEnc; :local vInterBr
	{:local ibp1 value=0; :local ibp2 value=0;
		:foreach i in=[/interface find type="bridge"] do={
			:set ibp1 value=[/interface bridge port print count-only where bridge=[/interface get $i value-name=name]];
			:if ($ibp1 > $ibp2) do={:set $ibp2 value=$ibp1; :set $vInterBr value=[/interface get $i value-name=name]}}};
	/certificate
	sign [add name=snmp-auth common-name=auth]; sign [add name=snmp-enc common-name=enc];
	:set value=[get snmp-auth fingerprint]; :set value=[get snmp-enc fingerprint];
	remove snmp-auth,snmp-enc;
	/snmp
	community set numbers=0 name=$vCommunity addresses=$vAddr security=private read-access=yes write-access=yes \
		authentication-protocol=SHA1 encryption-protocol=AES authentication-password=$vAuth encryption-password=$vEnc;
	set contact=$vContact location=$vLocat engine-id=[/system routerboard get serial-number] \
		trap-community=[/snmp community get 0 name] trap-version=3 enabled=yes;
	/ip firewall filter
	add chain=input comment="ADD_TEMP";
	print; :if ([find chain="input" protocol="udp" dst-port=161 in-interface=$vInterBr] = "") do={
		:if ([get number=0 action] = "passthrough") do={
			add chain="input" protocol="udp" dst-port=161 in-interface=$vInterBr action="accept" place-before=1 comment="SNMP Allow"} \
		else={chain="input" protocol="udp" dst-port=161 in-interface=$vInterBr action="accept" place-before=0 comment="SNMP Allow"}};
	remove numbers=[find comment="ADD_TEMP"];
	:put "Protocol SNMP successfully configured";
/}
