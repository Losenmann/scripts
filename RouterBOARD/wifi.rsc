:global funcWifi do={
	/interface{
		/wireless{
			:foreach i in=[find (band~"5ghz")] do={set number=$i band=5ghz-onlyac channel-width=20/40/80mhz-XXXX frequency=5190};
			:foreach i in=[find (band~"2ghz")] do={set number=$i band=2ghz-b/g/n channel-width=20/40mhz-XX frequency=auto};
		}
			:foreach i in=[find (type="wlan")] do={mode=ap-bridge ssid=inrate wireless-protocol=802.11 security-profile=default \
			frequency-mode=manual-txpower country=no_country_set installation=indoor wmm-support=enabled bridge-mode=enabled \
			multicast-helper=full tx-power-mode=all-rates-fixed disabled=no};
	}
}
