:global funcIptv do={
	:if ([/system package find name=multicast] = "") do={
		:local varVers value=[:pick [/system resource get version] 0 ([:find [/system resource get version] "("]-1)];
		:local varArch value=[/system resource get architecture-name];
		:if ($varArch = "x86") do={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers.npk"} \
			else={tool fetch "https://download.mikrotik.com/routeros/$varVers/multicast-$varVers-$varArch.npk"};
		system scheduler add name="Run IPTV Install" on-event="import iptv13.rsc" policy=reboot,read,write start-time=startup;
		:delay 3000ms;
		system reboot;
	};
	/interface{
	    wireless{
		    :foreach i in=[find (band~"5ghz")] do={:put test1};
		    :foreach i in=[find (band~"2ghz")] do={:put test2};
		}
	    :foreach i in=[/interface find (type="ether")] do={:put test3};
	}
/}
