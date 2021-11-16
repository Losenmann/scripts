:global funcIptv do={
	:if ([/system package find name=multicast = "") do={
		:local varVers value=[:pick [/system resource get version] 0 ([:find [/system resource get version] "("]-1)];
		:local varArch value=[/system resource get architecture-name];
		/tool fetch https://download.mikrotik.com/routeros/$varVers/multicast-$varVers-$varArch.npk;
		/system scheduler add name="Run IPTV Install" on-event="import iptv.rsc" policy=reboot,read,write start-time=startup;
		:delay 3000ms;
		/system reboot;
	}
	/routing igmp-proxy{
		interface add interface=[/ip dhcp-client get 0 interface] alternative-subnets=0.0.0.0/0 upstream="yes";
		interface add interface=[/ip dhcp-server get 0 interface];
	}
	/interface{
		bridge set [/ip dhcp-server get 0 interface] igmp-snooping="yes";
		:foreach i in=[find (type="wlan")] do={wmm-support="enabled" bridge-mode="enabled" multicast-helper="full"};
	}
	/ip firewall filter{
		:if ([find chain="input" protocol="igmp" in-interface=[/ip dhcp-server get 0 interface]] = "") do={
			add chain="input" protocol="igmp" in-interface=[/ip dhcp-server get 0 interface] action="accept" place-before="1" comment="IGMP Allow"};
			
		:if ([find chain="forward" protocol="udp" dst-port="1234"] = "") do={
			add chain="forward" protocol="udp" dst-port="1234" action="accept" place-before="2" comment="IPTV Forward"};
	}
/}
