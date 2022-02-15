:local vers "0.2"
# Variables: led,iptv
:global funcUpload do={
:local uri "https://raw.githubusercontent.com/Losenmann/scripts/master/RouterBOARD"
:local result
# Autoupdate
    :if ([{:local result [/tool/fetch https://raw.githubusercontent.com/Losenmann/scripts/master/RouterBOARD/upload.rsc as-value output=user];
        :pick ($result->"data") 13 16}] = $vers) do={
# LED Cintrol
        :if (led = "true") do={
            :set result [/tool/fetch $uri/ros7_led.rsc as-value output=user];
            :execute [($result->"data")];
        }
# IPTV Package
        :if (iptv = "true") do={
            :if ([:pick [/system/resource/get version] 0] >= 7) do={
                :set result [/tool/fetch $uri/ros6_iptv.rsc as-value output=user];
                :execute [($result->"data")];
            } else {
                :error "IPTV Already included in the system package"
            }
        }
# Wi-Fi Configure
        :if (wifi = "true") do={
            :set result [/tool/fetch $uri/ros6_wifi.rsc as-value output=user];
            :execute [($result->"data")];
        }
    } else={
        :set result [/tool/fetch $uri/upload.rsc as-value output=user];
        :execute [($result->"data")];
    }
}
