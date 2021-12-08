:global funcIptv do={
:local vInterWan;
:local vInterBr;
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
		set $vInterBr value=[ip route get number=[find dst-address=0.0.0.0/0] vrf-interface];
		/routing igmp-proxy
		interface add interface=$vInterWan alternative-subnets="0.0.0.0/0" upstream="yes";
		interface add interface=$vInterBr;
		/interface
		bridge set [/ip dhcp-server get 0 interface] igmp-snooping="yes";
		:foreach i in=[find (type="wlan")] do={wireless set $i wmm-support="enabled" bridge-mode="enabled" multicast-helper="full"};
		/ip firewall filter
		:if ([find chain="input" protocol="igmp" in-interface=$vInterBr] = "") do={
			:if ([get number=0 action] = "passthrough") do={
				add chain="input" in-interface=[/ip dhcp-server get 0 interface] protocol="igmp" action="accept" place-before=1 comment="IGMP Allow"} \
			else={add chain="input" in-interface=[/ip dhcp-server get 0 interface] protocol="igmp" action="accept" place-before=0 comment="IGMP Allow"}};
		:if ([find chain="forward" protocol="udp" dst-port="1234"] = "") do={
			add chain="forward" protocol="udp" dst-port="1234" action="accept" place-before="2" comment="IPTV Forward"};
		system scheduler remove "Run IPTV Install";
	}
/}
