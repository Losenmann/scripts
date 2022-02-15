:global funcIptv do={
/system resource
    :if ([..package find name=multicast] = "" && [:pick [get version] 0] < 7) do={
        :local uri value="https://download.mikrotik.com/routeros";
        :local ros value=[:pick [get version] 0 ([:find [get version] "("]-1)];
        :if ([get architecture-name] != "x86") do={:local arch value={"-".[get architecture-name]}};
        /tool fetch "$uri/$ros/multicast-$ros$arch.npk";
        /system scheduler add name="Run IPTV Install" on-event="/import iptv.rsc; \$funcIptv" start-time="startup";
        :delay 3s; /system reboot;
    } else={
        ..scheduler remove [find name="Run IPTV Install"];
        /routing igmp-proxy interface
        add interface=[ip route get [find dst-address=0.0.0.0/0 active=yes] vrf-interface] \
            alternative-subnets="0.0.0.0/0" upstream="yes"; add interface=all;
        /interface wireless
        :foreach i in=[..find type="wlan"] do={ \
            set $i wmm-support="enabled" multicast-helper="full";
        }; ..;
        :foreach i in=[find type="bridge"] do={ \
            bridge set $i igmp-snooping="yes";
        };
        /ip firewall filter
        :if ([find chain="input" protocol="igmp" action="accept"] = "") do={
            add chain="input" protocol="igmp" action="accept" comment="IGMP Allow" \
            in-interface=[ip route get [find dst-address=0.0.0.0/0 active=yes] vrf-interface] \
            place-before=[:if ([get number=0 action] = "passthrough") do={:return 1} else={:return 0}];
        } else={
            print;
            move destination=1 numbers=[find chain="input" protocol="igmp" action="accept"];
        };
        :if ([find chain="forward" protocol="udp" dst-port="1234" action="accept"] = "") do={
            add chain="forward" protocol="udp" dst-port="1234" action="accept" comment="IPTV Forward" place-before=1;
        } else={
            print;
            move destination=1 numbers=[find chain="forward" protocol="udp" dst-port="1234" action="accept"];
        };
        :put "Gateway successfully configured for IPTV";
    }
/}
