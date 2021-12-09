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
		set $vInterWan value=[ip route get number=[find dst-address=0.0.0.0/0] vrf-interface];
		{:local ibp1 value=0; :local ibp2 value=0;
		:foreach i in=[/interface find type="bridge"] do={
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
