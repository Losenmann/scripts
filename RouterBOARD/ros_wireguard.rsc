############### COVER ################
/system script add name="scrWgSetup" policy="read,write,policy,test" source={
################ BODY ################
############## FUNCTION ##############
:global funcWG do={
:local name="name1"
:local name="lookdst"
:local name="keydst"
:local name="keysrv"
:local port="13231"
:local point="host"
:local addr="172.19.20.1/24"
:local dns=[/ip/dns/get servers]
:local allow="0.0.0.0/0"
    :set name="name1" value=[/system/clock/get time];
    /interface/wireguard/
    add name=$name1;
    :set name="lookdst" value=[get number=[find name=$name1] private-key];
    :set name="keydst" value=[get number=[find name=$name1] public-key];
    :set name="keysrv" value=[get number=[find name="wg-srv"] public-key];
    remove numbers=[find name=$name1]
    /interface/wireguard/peers/
    add public-key=$keydst allowed-address="0.0.0.0/0" interface="wg-srv";
    /file/print file="wg.conf"
    :delay 1s;
    /file/set number=[find name="wg.conf.txt"] contents="[Interface]\nPrivateKey = $lookdst\nAddress = $addr\nDNS = $dns\n\n[Peer]\nPublicKey = $keysrv\nAllowedIPs = $allow\nEndpoint = $point:$port";
}
############## FUNCTION ##############
################ BODY ################
/system script run scrWgSetup
}
############### COVER ################
