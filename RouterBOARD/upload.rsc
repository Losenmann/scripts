############### COVER ################
/system script add name="scrUpload" policy="read,write,policy,test" source={
################ BODY ################
# To load one of the scripts, just pass the script name=value: led=true
# Implemented checking for new versions with each function call
# Supported scripts: led, iptv, wifi, adaway
############## FUNCTION ##############
:global funcUpload do={
:local version 0.4
:local uri "https://raw.githubusercontent.com/Losenmann/scripts/master/RouterBOARD"
:local result
# Autoupdate
    :if ([{:local result [/tool fetch "$uri/upload.rsc" as-value output=user];
        [:find ($result->"data") "version $version"]}] != "\$result") do={
# LED Cintrol
        :if (led = "true") do={
            set result [/tool fetch "$uri/ros7_led.rsc" as-value output=user];
            :execute [($result->"data")];
        }
# IPTV Package
        :if (iptv = "true") do={
            set result [/tool fetch "$uri/ros_iptv.rsc" as-value output=user];
            :execute [($result->"data")]; $funcIptv;
        }
# Wi-Fi Configure
        :if (wifi = "true") do={
            set result [/tool fetch "$uri/ros6_wifi.rsc" as-value output=user];
            :execute [($result->"data")];
        }
# Blocking ad hosts
        :if (adaway = "true") do={
            set result [/tool fetch "$uri/ros_adaway.rsc" as-value output=user];
            :execute [($result->"data")];
        }
    } else={
        /system/script/remove scrUpload;
        set result [/tool fetch "$uri/upload.rsc" as-value output=user];
        :execute [($result->"data")];
    }
}
############## FUNCTION ##############
################ BODY ################
};
/system script run scrUpload
############### COVER ################
