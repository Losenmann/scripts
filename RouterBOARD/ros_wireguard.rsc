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
:local dns [/ip/dns/get servers];
:local srv [:toarray {name="wg-srv";net="172.16.42.1/24"}];
:local host [:toarray {ip="";port="13231";allow="0.0.0.0/0"}];
:local mdata
:local sdata
:local tmp [/system/clock/get time];
/interface/wireguard/
    add name=$tmp disabled=yes;
    :if ([print count-only where name=($srv->"name")] <= 0) do={
        add name=($srv->"name");
    };
    :set mdata [:toarray ([get ($srv->"name") public-key],[get ($srv->"name") listen-port])];
    :set sdata [:toarray ([get "$tmp" private-key],[get "$tmp" public-key])];
    remove numbers="$tmp";
/interface/wireguard/peers/
    add public-key=($sdata->1) allowed-address="0.0.0.0/0" interface=($srv->"name");
    :set ($srv->"peer") [print count-only where interface=($srv->"name")];
/ip/address/
    :if ([print count-only where interface=($srv->"name")] <= 0) do={
        add address=($srv->"net") interface=($srv->"name");
    } else={
        :set ($host->"addr") [get [find interface=($srv->"name")] address];
    }
    :set ($host->"addr") [([:pick ($srv->"net") 0 [:find ($srv->"net") "/"]]+($srv->"peer"))];
    :set ($host->"addr") [(($host->"addr") . [:pick ($srv->"net") [:find ($srv->"net") "/"] [:len ($srv->"net")]])];
/file/
    print file=("ros-wg".($srv->"peer").conf);
    /system/identity/export file=("ros-wg".($srv->"peer"));
    :delay 1s;
    :local addr ($host->"addr"); :local allow ($host->"allow"); :local sdata ($sdata->0);
    :local mdata ($mdata->0); :local ip ($host->"ip"); :local port ($host->"port");
# Standard config file
    set number=[find name="wg.conf.txt"] contents="\
[Interface]\r\
PrivateKey = $sdata\r\
Address = $addr\r\
DNS = $dns\r\
\r\
[Peer]\r\
PublicKey = $mdata\r\
AllowedIPs = $allow\r\
Endpoint = $ip:$port$host";
# Script for devices on RouterOS
    set number=[find name=("ros-wg".($srv->"peer").".rsc")] contents="\
/interface/wireguard/\r\
add private-key=\"$sdata\";\r\
:local wgname [get [find private-key=$sdata] name]\r\
/interface/wireguard/peers/\r\
add interface=\$wgname public-key=\"$mdata\" endpoint-address=\"$ip\" endpoint-port=\"$port\" allowed-address=\"$allow\"\r\
/ip/address/\r\
add address=\"$addr\" interface=\$wgname";
}
############## FUNCTION ##############
################ BODY ################
/system script run scrWgSetup
}
############### COVER ################
