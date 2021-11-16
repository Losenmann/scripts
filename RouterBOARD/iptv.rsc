:global funcIptv do={
	:if ([/system package find name=multicast] = "") do={
		:local varVers value=[:pick [/system resource get version] 0 ([:find [/system resource get version] "("]-1)];
		:local varArch value=[/system resource get architecture-name];
		/tool fetch https://download.mikrotik.com/routeros/$varVers/multicast-$varVers-$varArch.npk;
		/system scheduler add name="Run IPTV Install" on-event="import iptv.rsc" policy=reboot,read,write start-time=startup;
		:delay 3000ms;
		/system reboot;
	}
}
