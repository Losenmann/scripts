:global funcIptv do={
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
