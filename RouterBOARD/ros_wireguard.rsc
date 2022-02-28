############### COVER ################
/system script add name="scrWgSetup" policy="read,write,policy,test" source={
################ BODY ################
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
    :set ($host->"addr") [([:pick ($srv->"net") 0 [:find ($srv->"net") "/"]]+([print count-only where interface=($srv->"name")]))];
    :set ($host->"addr") [(($host->"addr") . [:pick ($srv->"net") [:find ($srv->"net") "/"] [:len ($srv->"net")]])];
/ip/address/
    :if ([print count-only where interface=($srv->"name")] <= 0) do={
        add address=($srv->"net") interface=($srv->"name");
    } else={
        :set ($host->"addr") [get [find interface=($srv->"name")] address];
    }
/file/
    print file="wg.conf";
    :delay 1s;
    :local addr ($host->"addr"); :local allow ($host->"allow"); :local sdata ($sdata->0);
    :local mdata ($mdata->0); :local host (($host->"ip").":".($host->"port"));
    set number=[find name="wg.conf.txt"] contents="\
[Interface]\r\
PrivateKey = $sdata\r\
Address = $addr\r\
DNS = $dns\r\
\r\
[Peer]\r\
PublicKey = $mdata\r\
AllowedIPs = $allow\r\
Endpoint = $host";
}
############## FUNCTION ##############
################ BODY ################
/system script run scrWgSetup
}
############### COVER ################
