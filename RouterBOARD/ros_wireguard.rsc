############### COVER ################
/system script add name="scrWgSetup" policy="read,write,policy,test" source={
################ BODY ################
# The script allows you to quickly configure Wireguard if it is not already configured
# If the WG server is already configured, then the output will generate a configuration file for connecting
# Pay attention to the default values if nothing is passed to the function
# Upon successful execution of the function, 2 files are created: .txt and .rsc.
# It is enough to transfer the .rsc file to another RouterOS device and import it.
# To use the .txt configuration file on other devices, you may need to change the extension to .conf
############## FUNCTION ##############
:global funcWG do={
/ip/cloud/set ddns-enabled="yes";
:local dns [/ip/dns/get servers];
:local srv [:toarray {name="wg-srv";net="172.16.42.1/24"}];
:local host [:toarray {ip="[/ip/cloud/get dns-name]";port="13231";allow="0.0.0.0/0"}];
:local mdata
:local sdata
:local tmp [/system/clock/get time];
/interface/wireguard/
    add name=$tmp disabled=yes;
    :if ([:len [find where name=($srv->"name")]] <= 0) do={
        add name=($srv->"name") listen-port=($host->"port");
    };
    :set mdata [:toarray ([get ($srv->"name") public-key])];
    :set ($host->"port") [get ($srv->"name") listen-port];
    :set sdata [:toarray ([get "$tmp" private-key],[get "$tmp" public-key])];
    remove numbers="$tmp";
/interface/wireguard/peers/
    add public-key=($sdata->1) allowed-address="0.0.0.0/0" interface=($srv->"name");
    :set ($srv->"peer") [:len [find where interface=($srv->"name")]];
/ip/address/
    :if ([:len [find where interface=($srv->"name")]] <= 0) do={
        add address=($srv->"net") interface=($srv->"name");
    } else={
        :set ($host->"addr") [get [find interface=($srv->"name")] address];
    }
    :set ($host->"addr") [([:pick ($srv->"net") 0 [:find ($srv->"net") "/"]]+($srv->"peer"))];
    :set ($host->"addr") [(($host->"addr") . [:pick ($srv->"net") [:find ($srv->"net") "/"] [:len ($srv->"net")]])];
/file/
    print file=("ros-wg".($srv->"peer"));
    /system/identity/export file=("ros-wg".($srv->"peer"));
    :delay 1s;
    :local addr ($host->"addr"); :local allow ($host->"allow"); :local sdata ($sdata->0);
    :local mdata ($mdata->0); :local ip ($host->"ip"); :local port ($host->"port");
# Standard config file
    :do {set number=[find name=("ros-wg".($srv->"peer").".txt")] contents="\
[Interface]\r\
PrivateKey = $sdata\r\
Address = $addr\r\
DNS = $dns\r\
[Peer]\r\
PublicKey = $mdata\r\
AllowedIPs = $allow\r\
Endpoint = $ip:$port";
:put "Main config file created successfully";
    } on-error={
        :put "Main file creation error";
    }
# Script for devices on RouterOS
    :do {set number=[find name=("ros-wg".($srv->"peer").".rsc")] contents="\
/interface/wireguard/\r\
add private-key=\"$sdata\";\r\
:local wgname [get [find private-key=\"$sdata\"] name];\r\
/interface/wireguard/peers/\r\
add interface=\$wgname public-key=\"$mdata\" endpoint-address=\"$ip\" endpoint-port=\"$port\" allowed-address=\"$allow\";\r\
/ip/address/\r\
add address=\"$addr\" interface=\$wgname;";
:put "Configuration file .rsc created successfully";
    } on-error={
        :put "File creation .rsc error";
    }
}
############## FUNCTION ##############
################ BODY ################
/system script run scrWgSetup
}
############### COVER ################
