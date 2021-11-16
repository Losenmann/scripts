:global funcIptv do={
	:if ([/system package find name=multicast] = "") do={
		:local varVers value=[:pick [/system resource get version] 0 ([:find [/system resource get version] "("]-1)];
		:local varArch value=[/system resource get architecture-name];
		:if ($varArch = "x86") do={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers.npk"} \
			else={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers-$varArch.npk"};
		system scheduler add name="Run IPTV Install" on-event="import iptv8.rsc" policy=reboot,read,write start-time=startup;
	}
}
