############### COVER ################
/system script add name="scrWgSetup" policy="read,write,policy,test" source={
################ BODY ################
############## FUNCTION ##############
:global funcWG do={
:local name="name1"
:local name="lookdst"
:local name="keydst"
:local name="keysrv"
:set name="name1" value=[/system/clock/get time];
/interface/wireguard/
add name=$name1;
:set name="lookdst" value=[get number=[find name=$name1] private-key];
:set name="keydst" value=[get number=[find name=$name1] public-key];
:set name="keysrv" value=[get number=[find name="wg-srv"] public-key];
/interface/wireguard/peers/
add public-key=$keydst allowed-address="0.0.0.0/0" interface="wg-srv";
/file/print file="wg.conf"
:delay 1s;
/file/set number=[find name="wg.conf.txt"] contents="[Interface]\nPrivateKey = $lookdst\nAddress = 172.16.42.2/26\nDNS = 192.168.8.1\n\n[Peer]\nPublicKey = $keysrv\nAllowedIPs = 0.0.0.0/0\nEndpoint = inrate.xyz:25694";
}
############## FUNCTION ##############
################ BODY ################
}
############### COVER ################
