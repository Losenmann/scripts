:global funcWDS do={
:local vMode; 
:local vPower;
:local vShortGI;
:local vSsid; :local vPsk;
:local vInterBr;
	:if ($vMode = 0 or $vMode = 1) do={
		:if ($vMode = 0) do={:put "Configure AP mode"}
		:if ($vMode = 1) do={:put "Configure ST mode"}
	} else {
	:error "Err 04: Invalid mode specified";
	}
	:if ([:len $vPower] = 0) do={:set $vPower value=10} else {:if ($vPower > 27) do={:error "Err 05: Installed unacceptable power"}}
	:if ([:len $vShortGI] = 0) do={:set $vShortGI value="long"} else {:if ($vShortGI = "long" or $vShortGI = "any") do={} else {:error "Err 06: Installed unacceptable guard interval"}};
	:if ([:len $vSsid] = 0) do={:set $vSsid value="Secure_AP"}
	:if ([:len $vPsk] < 8) do={
		:for i from=0 to=([:len [/interface get number=0 mac-address]] - 1) do={
			:local char [:pick [/interface get number=0 mac-address] $i]; :if ($char = ":") do={
				:set $char ""}; :set $vPsk ($vPsk.$char)}};
	/interface
	if (0<[bridge print count-only]) do={
		:foreach i in=[find type="bridge"] do={
			:set ibp1 value=0;
			:set ibp2 value=[bridge port print count-only where bridge=[get $i name]];
			:if ($ibp2 > $ibp1) do={
				:set $ibp1 value=$ibp2; :set $vInterBr value=[get $i name];
			}
		}
	} else {
		bridge add name=bridge1;
		:set $vInterBr value="bridge1";
	}
	:foreach i in=[find (type!="bridge")] do={
		bridge port add bridge=$vInterBr interface=[get $i name]};
	}
	:foreach i in=[find type="wlan"] do={
		:if ([wireless get $i band] ~ "2ghz") do={
			wireless :set name=$i ssid=$vSsid country="united states" frequency-mode=superchannel installation=outdoor \
			wireless-protocol=nv2 nv2-security=enabled nv2-preshared-key=$vPsk tx-power-mode=all-rates-fixed tx-power=$vPower \
			guard-interval=$vShortGI mode=bridge station-roaming=enabled wds-default-bridge=$vInterBr wds-mode=dynamic \
			band=2ghz-onlyn frequency=5520 channel-width=20/40mhz-Ce disabled=no;
			:if ($vMode = 0) do={:set name=$i mode=bridge} else {:set name=$i mode=station-bridge}
		}
		:if ([wireless get $i band] ~ "5ghz") do={
			wireless :set name=$i ssid=$vSsid country="united states" frequency-mode=superchannel installation=outdoor \
			wireless-protocol=nv2 nv2-security=enabled nv2-preshared-key=$vPsk tx-power-mode=all-rates-fixed tx-power=$vPower \
			guard-interval=$vShortGI mode=bridge station-roaming=enabled wds-default-bridge=$vInterBr wds-mode=dynamic \
			band=5ghz-onlyn frequency=5520 channel-width=20/40mhz-Ce disabled=no;
			:if ($vMode = 0) do={:set name=$i mode=bridge} else {:set name=$i mode=station-bridge}
		}
		:if ([wireless get $i band] ~ "60ghz") do={
			wireless :set name=$i ssid=$vSsid country="united states" frequency-mode=superchannel installation=outdoor \
			wireless-protocol=nv2 nv2-security=enabled nv2-preshared-key=$vPsk tx-power-mode=all-rates-fixed tx-power=$vPower \
			guard-interval=$vShortGI mode=bridge station-roaming=enabled wds-default-bridge=$vInterBr wds-mode=dynamic \
			band=60ghz-onlyn frequency=5520 channel-width=20/40mhz-Ce disabled=no;
			:if ($vMode = 0) do={:set name=$i mode=bridge} else {:set name=$i mode=station-bridge}
		}
	}
	/ip
	dhcp-client add interface=$vInterBr disabled=no;
	service disable api,api-ssl,ftp,telnet,www-ssl;
	neighbor discovery-settings set discover-interface-list=!dynamic;
	/system
	identity set name="MikroTik AP"
	clock set time-zone-name=Asia/Novosibirsk
	/tool
	bandwidth-server set enabled=no
	/snmp
	set contact=virus14m@gmail.com enabled=yes location="Solnechnay 1" trap-version=2
	community set [find default=yes] addresses=192.168.8.0/24 name=losenet write-access
/}
