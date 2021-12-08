:global funcWifi do={
	/interface{
		/wireless{
			security-profiles set numbers=0 mode=dynamic-keys authentication-types=wpa2-psk unicast-ciphers=aes-ccm group-ciphers=aes-ccm wpa2-pre-shared-key=$vPsk
			:foreach i in=[find (type="wlan")] do={reset-configuration numbers=$i};
			:foreach i in=[find (band~"5ghz")] do={set number=$i band=5ghz-onlyac channel-width=20/40/80mhz-XXXX ssid=$vSsid2};
			:foreach i in=[find (band~"2ghz")] do={set number=$i band=2ghz-b/g/n channel-width=20/40mhz-XX ssid=$vSsid5};
		}
			:foreach i in=[find (type="wlan")] do={set mode=ap-bridge wireless-protocol=802.11 security-profile=default \
			frequency-mode=manual-txpower country=no_country_set installation=indoor wmm-support=enabled bridge-mode=enabled \
			multicast-helper=full tx-power-mode=all-rates-fixed tx-power=17 disabled=no};
	}
/}
